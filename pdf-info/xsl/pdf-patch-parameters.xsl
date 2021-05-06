<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="c:info[@name eq 'Page size']">
    <xsl:variable name="width-pt" select="replace(@value, '^([\d\.?]+).+$', '$1')" as="xs:string"/>
    <xsl:variable name="width-mm" select="if($width-pt castable as xs:decimal) 
                                          then format-number(xs:decimal($width-pt) * 0.352778, '0.0 mm') 
                                          else $width-pt" as="xs:string"/>
    <xsl:variable name="height-pt" select="replace(@value, '^.+?([\d\.?]+)\s*pts.*$', '$1')" as="xs:string"/>
    <xsl:variable name="height-mm" select="if($height-pt castable as xs:decimal) 
                                           then format-number(xs:decimal($height-pt) * 0.352778, '0.0 mm') 
                                           else $height-pt" as="xs:string"/>
    <c:info name="Page width" value="{$width-mm}"/>
    <c:info name="Page height" value="{$height-mm}"/>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>