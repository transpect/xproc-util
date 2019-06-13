<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
	  xmlns:pxf="http://exproc.org/proposed/steps/file"
	  xmlns:pxp="http://exproc.org/proposed/steps"
	  xmlns:tr="http://transpect.io"
	  xmlns:cx="http://xmlcalabash.com/ns/extensions"
	  version="1.0"
    type="tr:extract-from-jar"
    name="extract-from-jar">
  
  <p:documentation>
    Extends the pxp:unzip step to extract files from a jar file.
  </p:documentation>
	
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="href" required="true">
    <p:documentation>URI where the file to extract is located</p:documentation>
  </p:option>
  <p:option name="dest-dir" required="true">
    <p:documentation>URI where the file should be stored.</p:documentation>
  </p:option>
  
  <p:variable name="jar-href"
      select="replace($href, '(jar|zip):([^!]+)!.*', '$2')"/>
  
  <p:variable name="file-rel-path"
      select="replace($href, '(jar|zip):[^!]+!/(.+)', '$2')"/>
  
  <p:variable name="filename"
      select="replace($file-rel-path, '^(.+?)([^/^\\]+\..+)$', '$2')"/>
  
  <cx:message name="msg2">
    <p:input port="source">
      <p:inline>
        <p:empty/>
      </p:inline>
    </p:input>
      <p:with-option name="message" select="'HREF ', $href, 'JARPATH', $jar-href, 'FILERELPATH', $file-rel-path, ' NAME', $filename">
      </p:with-option>
    </cx:message>
  
  
  <pxp:unzip name="unzip" content-type="application/zip">
    <p:with-option name="href" select="$jar-href"/>
    <p:with-option name="file" select="$file-rel-path"/>
  </pxp:unzip>
  
  <p:store cx:decode="true">
    <p:with-option name="href" select="concat($dest-dir, '/', $filename)"/>
  </p:store>
  
  <p:add-attribute match="/*">
    <p:input port="source">
      <p:inline>
        <c:result/> 
      </p:inline>
    </p:input>
    <p:with-option name="attribute-name" select="'local-href'"/>
    <p:with-option name="attribute-value" select="concat($dest-dir, '/', $filename)"/>
  </p:add-attribute>

</p:declare-step>