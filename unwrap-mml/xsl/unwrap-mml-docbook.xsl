<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="xs tr mml css"
  xmlns="http://docbook.org/ns/docbook" 
  version="2.0">
  
  <!-- dissolves inline equations in DocBook by utilizing the unwrap-mml.xsl stylesheet 
    
       invoke from command line:
       $ saxon -xsl:xsl/unwrap-mml-hub.xsl -s:source.xml -o:output.xml

  -->
  
  <xsl:import href="unwrap-mml.xsl"/>
  
  <xsl:template match="*:inlineequation[mml:math[tr:unwrap-mml-boolean(.)]]">
    <xsl:apply-templates mode="unwrap-mml"/>
  </xsl:template>
  
  <xsl:template match="*:equation[mml:math[tr:unwrap-mml-boolean(.)]]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#default"/>
      <xsl:apply-templates mode="unwrap-mml"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
