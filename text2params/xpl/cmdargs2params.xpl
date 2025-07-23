<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="cmdargs2params"
  type="tr:cmdargs2params">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Converts Command-Line Arguments (cmd-args) to &lt;c:param-set&gt;.</p>
    <p>Example input (option 'cmdargs'): 'saxon.sh -xsl:docx2hub/xsl/main.xsl -im:{http://transpect.io/docx2hub}join-runs -s:in.xml fail-on-error="no" VERSION=1.0 debug= debug-dir-uri=/path/to/debug?indent=true'. 
       Expected output: &lt;c:param-set&gt;
       &lt;c:param name="-xsl" value="docx2hub/xsl/main.xsl"/&gt;
       &lt;c:param name="-im" value="{http://transpect.io/docx2hub}join-runs"/&gt;
       &lt;c:param name="-s" value="in.xml"/&gt;
       &lt;c:param name="fail-on-error" value="no"/&gt;
       &lt;c:param name="VERSION" value="1.0"/&gt;
       &lt;c:param name="debug" value=""/&gt;
       &lt;c:param name="debug-dir-uri" value="/path/to/debug?indent=true"/&gt;
     &lt;/c:param-set&gt;</p>
  </p:documentation>

  <p:option name="cmdargs" required="true"/>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:output port="result" primary="true"/>
  <p:serialization port="result" indent="true" omit-xml-declaration="false"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:xslt name="xslt" template-name="main">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" exclude-result-prefixes="#all">
          <xsl:param name="cmdargs"/>
          <xsl:param name="debug"/>
          <xsl:template name="main">
            <c:param-set>
              <xsl:if test="$debug = 'yes'">
                <xsl:processing-instruction name="cmdargs-value" select="$cmdargs"/>
              </xsl:if>
              <xsl:for-each select="tokenize(
                                      replace(
                                        replace(
                                          $cmdargs, 
                                          '(^|\s+)?([-][-\p{L}]+[:])', 
                                          '_##SEP##_$2'), 
                                        '(^|\s+)([^=]+=)', 
                                        '_##SEP##_$2'), 
                                      '_##SEP##_'
                                    )[matches(., '[:=]')]">
                <c:param 
                  name="{replace(
                           replace(
                             ., 
                             '^([^=]+)=.*$', 
                             '$1'), 
                           '^([-\p{L}]+)[:].*$', 
                           '$1'
                         )}" 
                  value="{replace(
                            replace(
                              replace(
                                ., 
                                '^[^=]+=(.*)\s?$', 
                                '$1'),
                              '^([-\p{L}]+)[:](.*)$',
                              '$2'),
                            '^&quot;(.+)&quot;$', 
                            '$1')}"/>
              </xsl:for-each>
            </c:param-set>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:with-param name="cmdargs" select="$cmdargs"/>
    <p:with-param name="debug" select="$debug"/>
  </p:xslt>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="'cmdargs2params/result'"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>
