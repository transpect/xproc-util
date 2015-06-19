<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io" 
  exclude-result-prefixes="xs" version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/hex/xsl/hex.xsl"/>
  
  <xsl:param name="uri" as="xs:string"/>
  
  <xsl:template name="main">
    <c:result>
      <xsl:sequence select="tr:unescape-uri($uri)"/>
    </c:result>
  </xsl:template>
  
</xsl:stylesheet>