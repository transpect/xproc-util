<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:functx="http://www.functx.com"
  version="2.0">
  
  <xsl:param name="insert-srcpaths"/>
  <xsl:param name="exclude-elements"/>
  <xsl:param name="exclude-descendants"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[not(name() = tokenize($exclude-elements, '\s') 
    or ($exclude-descendants eq 'yes' and ancestor::*/name() = tokenize($exclude-elements, '\s')))]">
    <xsl:copy>
      <xsl:attribute name="srcpath" select="functx:path-to-node-with-pos(.)"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="functx:path-to-node-with-pos" as="xs:string" 
    xmlns:functx="http://www.functx.com" >
    <xsl:param name="node" as="node()?"/> 
    
    <xsl:variable name="names" as="xs:string*">
      <xsl:for-each select="$node/ancestor-or-self::*">
        <xsl:variable name="ancestor" select="."/>
        <xsl:variable name="sibsOfSameName"
          select="$ancestor/../*[name() = name($ancestor)]"/>
        <xsl:sequence select="concat(name($ancestor),
          if (count($sibsOfSameName) &lt;= 1)
          then ''
          else concat(
          '[',functx:index-of-node($sibsOfSameName,$ancestor),']'))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($names,'/')"/>
    
  </xsl:function>
  
  <xsl:function name="functx:index-of-node" as="xs:integer*" 
    xmlns:functx="http://www.functx.com" >
    <xsl:param name="nodes" as="node()*"/> 
    <xsl:param name="nodeToFind" as="node()"/> 
    
    <xsl:sequence select=" 
      for $seq in (1 to count($nodes))
      return $seq[$nodes[$seq] is $nodeToFind]
      "/>
    
  </xsl:function>
  
  
</xsl:stylesheet>