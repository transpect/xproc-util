<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="self::*:result">
        <xsl:attribute name="rel-path" select="tr:uri-to-relative-path(concat('file:/', @cwd, '/'), @local-href)"/>  
      </xsl:if>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>