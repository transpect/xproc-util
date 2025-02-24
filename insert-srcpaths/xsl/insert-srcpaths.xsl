<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:functx="http://www.functx.com"
  version="2.0">
  
  <xsl:param name="schematron-like-paths" select="'no'"/>
  <xsl:param name="override-existing-srcpaths" select="'no'"/>
  <xsl:param name="exclude-elements"/>
  <xsl:param name="exclude-descendants"/>
  <xsl:param name="prepend" as="xs:string?"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*" priority="0.5">
    <xsl:param name="ancestor-srcpath" select="''" tunnel="no"/>
    <xsl:variable name="srcpath"
      select="tr:create-srcpath(., $ancestor-srcpath)"/>
    <xsl:copy>
      <xsl:if test="not(@srcpath) or $override-existing-srcpaths = 'yes'">
        <xsl:attribute name="srcpath" select="$srcpath"/>
      </xsl:if>
      <xsl:apply-templates select="@*, node()" mode="#current">
        <xsl:with-param name="ancestor-srcpath" select="$srcpath" tunnel="no"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[name() = tokenize($exclude-elements, '\s')]" priority="2">
    <xsl:param name="ancestor-srcpath" select="''" tunnel="no"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()">
        <xsl:with-param name="ancestor-srcpath" select="tr:create-srcpath(., $ancestor-srcpath)" tunnel="no"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[name() = tokenize($exclude-elements, '\s')][$exclude-descendants eq 'yes']" priority="3">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:function name="tr:create-srcpath" as="xs:string">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="ancestor-srcpath" as="xs:string?"/>
    <xsl:variable name="node-name" select="name($node)"/>
    <xsl:sequence 
      select="string-join((
                            $prepend,
                            $ancestor-srcpath,
                            '/',
                            if($schematron-like-paths eq 'yes')
                              then concat('*:', local-name($node), '[namespace-uri()=''', namespace-uri($node), ''']')
                              else $node-name,
                            '[', count($node/preceding-sibling::*[name() = $node-name]) + 1, ']'
                          ), '')"/>
  </xsl:function>
  
</xsl:stylesheet>