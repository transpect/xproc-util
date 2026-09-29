<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io" 
  version="3.1"
  name="escape-for-uri" 
  type="tr:escape-for-uri">

  <p:option name="path"/>
  
  <p:output port="result" primary="true">
    <p:documentation>c:result element with the %HH-unescaped string as text content.</p:documentation>
  </p:output>
  
  <p:xslt name="unescape" template-name="main">
    <p:with-input port="source"><p:empty/></p:with-input>
    <p:with-input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:import href="http://transpect.io/xslt-util/resolve-uri/xsl/resolve-uri.xsl"/>
          <xsl:param name="path" as="xs:string"/>
          <xsl:template name="main">
            <c:result>
              <xsl:sequence select="tr:encode-for-uri($path)"/>
            </c:result>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:with-input>
    <p:with-option name="parameters" select="map { 'path': $path }"/>
  </p:xslt>
  
</p:declare-step>
