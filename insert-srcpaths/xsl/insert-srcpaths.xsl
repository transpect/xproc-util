<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:functx="http://www.functx.com"
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/functx/xsl/functx.xsl"/>
  
  <xsl:param name="insert-srcpaths"/>
  <xsl:param name="exclude-elements"/>
  <xsl:param name="exclude-descendants"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[not(name() = tokenize($exclude-elements, '\s') 
                         or ($exclude-descendants eq 'yes' 
                         and ancestor::*/name() = tokenize($exclude-elements, '\s')))]">
    <xsl:copy>
      <xsl:attribute name="srcpath" select="functx:path-to-node-with-pos(.)"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>