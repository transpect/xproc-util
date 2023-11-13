<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub">
  
  
  <xsl:param name="outfile-prefix"/>
  <xsl:param name="pad-position"/>
  <xsl:param name="pad"/>
  
  <xsl:function name="tr:pad-postion">
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:sequence select="if ($pad-position='true') 
                         then concat(string-join((for $i in 1 to xs:integer($pad - string-length(xs:string($pos))) return '0'),''),$pos)
                         else $pos"/>
  </xsl:function>
  
  <xsl:template match="mml:math">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:variable name="pos" select="tr:pad-postion(count(preceding::mml:math) + 1)"/>
      <xsl:attribute name="position" select="$pos"/>
      <xsl:if test="ancestor::*:inlineequation">
        <xsl:attribute name="inline" select="true()"/>
      </xsl:if>
      <xsl:attribute name="filename" select="concat($outfile-prefix, $pos)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | * | processing-instruction() | comment()" mode="#all" priority="-2">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="#all" priority="-1">
    <xsl:value-of select="."/>
  </xsl:template>
</xsl:stylesheet>