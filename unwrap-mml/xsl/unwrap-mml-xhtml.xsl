<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="#all"
  version="2.0">  

  <!-- unwrap MathML equations in XHTML by utilizing the unwrap-mml.xsl stylesheet 
    
       invoke from command line:
       $ saxon -xsl:xsl/unwrap-mml-xhtml.xsl -s:source.xml -o:output.xml

  -->
  
  <xsl:import href="unwrap-mml.xsl"/>
  
  <xsl:output method="xhtml"/>

  <xsl:param name="superscript" as="element()">
    <sup xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:param>
  <xsl:param name="subscript" as="element()">
    <sub xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:param>
  <xsl:param name="italic" as="element()">
    <i xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:param>
  <xsl:param name="bold" as="element()">
    <b xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:param>
  <xsl:param name="bold-italic" as="element()">
    <b style="font-style:italic" xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:param>
  
  <xsl:template match="mml:math[tr:unwrap-mml-boolean(.)]">
    <xsl:apply-templates mode="unwrap-mml"/>          
  </xsl:template>

  <xsl:template match="mml:math[tr:unwrap-mml-boolean(.)]//text()[matches(., '^[\n\p{Zs}&#x200b;-&#x200f;]+$')]"/>
    
</xsl:stylesheet>
