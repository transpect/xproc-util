<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http:/xmlcalabash.com/ns/extensions"
  xmlns:pos="http://exproc.org/proposed/steps/os"
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="tr-pdf-info"
  type="tr:pdf-info">

  <p:documentation>
    An XProc wrapper for Poppler's pdfinfo. This step 
    needs Poppler to be installed on the system.
  </p:documentation>

  <p:output port="result" sequence="true"/>
  
  <p:option name="file" required="true"/>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <pos:info name="os-info"/>
  
  <tr:file-uri name="pdfinfo-href">
    <p:with-option name="filename" select="if(matches(/c:result/@os-name, 'windows', 'i')) 
                                           then 'C:/cygwin64/bin/pdfinfo.exe'
                                           else '/usr/bin/pdfinfo'"/>
  </tr:file-uri>

  <p:sink/>

  <tr:file-uri name="file-href">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <p:try>
    <p:group>
      
      <p:exec name="exec" wrap-error-lines="true" wrap-result-lines="true" result-is-xml="false">
        <p:with-option name="command" select="/c:result/@os-path">
          <p:pipe port="result" step="pdfinfo-href"/>
        </p:with-option>
        <p:with-option name="args" select="/c:result/@os-path">
          <p:pipe port="result" step="file-href"/>
        </p:with-option>
        <p:input port="source">
          <p:empty/>
        </p:input>
      </p:exec>
      
      <tr:store-debug>
        <p:with-option name="pipeline-step" select="concat('pdf-info/', /c:result/@lastpath)">
          <p:pipe port="result" step="file-href"/>
        </p:with-option>
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:xslt cx:depends-on="exec">
        <p:input port="stylesheet">
          <p:document href="../xsl/pdf-info.xsl"/>
        </p:input>
        <p:with-param name="file" select="$file"/>
      </p:xslt>
      
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="../xsl/pdf-patch-parameters.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
      
    </p:group>
    <p:catch name="catch">
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
      </p:identity>
      
      <p:add-attribute match="/c:errors" attribute-name="href">
        <p:with-option name="attribute-value" select="$file"/>
      </p:add-attribute>
      
      <p:add-attribute match="/c:errors" attribute-name="type" attribute-value="pdfinfo"/>
      
    </p:catch>
    
  </p:try>
  
</p:declare-step>