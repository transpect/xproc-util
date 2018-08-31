<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:mml2tex="http://transpect.io/mml2tex"
  exclude-result-prefixes="#all"   
  version="2.0">
  
  <!-- dissolves inline equations in A++ by utilizing the unwrap-mml.xsl stylesheet 
    
       please note that you have to manually replace the string "FITZLIBUTZI" with "EquationSource"
       as shown below. This is needed because A++ encapsulate TeX code with CDATA sections and XSLT 2.0
       just accepts QNames as value for @cdata-section-elements.
    
       invoke from command line:
       $ saxon -xsl:xsl/unwrap-mml-aplusplus.xsl -it:main -s:source.xml | sed -u 's/\(FITZLIBUTZI\)/EquationSource/g'
  -->
  
  <xsl:import href="unwrap-mml.xsl"/>
  
  <xsl:output cdata-section-elements="EquationSource" 
              doctype-public="-//Springer-Verlag//DTD A++ V2.4//EN" 
              doctype-system="http://devel.springer.de/A++/V2.4/DTD/A++V2.4.dtd"/>
  
  <xsl:param name="debug" select="'no'"/>
  
  <xsl:param name="superscript" as="element()">
    <Superscript/>
  </xsl:param>
  <xsl:param name="subscript" as="element()">
    <Subscript/>
  </xsl:param>
  <xsl:param name="italic" as="element()">
    <Emphasis Type="Italic"/>
  </xsl:param>
  <xsl:param name="bold" as="element()">
    <Emphasis Type="Bold"/>
  </xsl:param>
  <xsl:param name="bold-italic" as="element()">
    <Emphasis Type="BoldItalic"/>
  </xsl:param>
  <xsl:param name="whitespace-wrapper-for-operators" select="'&#x2009;'" as="xs:string*"/>
  <xsl:param name="operator-limit" select="2" as="xs:integer"/>
  
  <!--  *
        * mode "delete-mml-ns" drop the temporary mml namespace
        * -->
  
  <xsl:template match="mml:*" mode="delete-mml-ns">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>  

  <!--  *
        * mode "unwrap-mml" invokes unwrap-mml module
        * -->
  
  <xsl:template match="InlineEquation[EquationSource[@Format eq 'MATHML']/mml:math[tr:unwrap-mml-boolean(.)]]" mode="apply-unwrap-mml">
    <xsl:if test="$debug eq 'yes'">
      <xsl:comment select="@ID, 'flattened'"/>
    </xsl:if>
    <xsl:apply-templates select="EquationSource[@Format eq 'MATHML']/mml:math[tr:unwrap-mml-boolean(.)]" mode="unwrap-mml"/>
  </xsl:template>
  
  <xsl:template match="EquationSource[not(@Format eq 'TEX')]" mode="apply-unwrap-mml" priority="-1">
    <FITZLIBUTZI>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </FITZLIBUTZI>
  </xsl:template>
  
  <xsl:template match="mml:msubsup[not(.//*[local-name() = ('msub', 'msup', 'msubsup')])]" mode="unwrap-mml">
    <xsl:apply-templates select="*[1]" mode="#current"/>
    <Stack>
      <Subscript>
        <xsl:apply-templates select="*[2]" mode="#current"/>  
      </Subscript>
      <Superscript>
        <xsl:apply-templates select="*[3]" mode="#current"/>
      </Superscript>
    </Stack>
  </xsl:template>
  
  <!-- override function for Stack element, allow msubsup -->
  
  <xsl:function name="tr:unwrap-mml-boolean" as="xs:boolean">
    <xsl:param name="math" as="element(mml:math)"/>
    <xsl:sequence select="count($math//mml:mo[not(matches(., concat('^', $whitespace-regex, '|', $parenthesis-regex, '$')))]) le $operator-limit
                          and not(  $math//mml:mfrac[not(string-join(*, '/') = $fractions//mml:frac/@value)] 
                                 or $math//mml:mroot
                                 or $math//mml:msqrt
                                 or $math//mml:mtable
                                 or $math//mml:mmultiscripts
                                 or $math//mml:mphantom
                                 or $math//mml:mstyle
                                 or $math//mml:mover
                                 or $math//mml:munder
                                 or $math//mml:munderover
                                 or $math//mml:menclose
                                 or $math//mml:merror
                                 or $math//mml:maction
                                 or $math//mml:mglyph
                                 or $math//mml:mlongdiv
                                 or $math//mml:msup[.//mml:msub|.//mml:msup|.//mml:msubsup]
                                 or $math//mml:msub[.//mml:msub|.//mml:msup|.//mml:msubsup]
                                 or $math//mml:msubsup[.//mml:msub|.//mml:msup|.//mml:msubsup]
                                 )"/>
  </xsl:function>

  <xsl:template match="mml:math[tr:unwrap-mml-boolean(.)]//text()[matches(., concat('^', $whitespace-regex, '+$'))]" mode="unwrap-mml"/>
  
  <!--  *
        * mode "attach-mml-ns" add mathml namespace
        * -->
  
  <xsl:template match="math|math//*" mode="attach-mml-ns">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- micro pipeline -->
  
  <xsl:template name="main">
    <xsl:sequence select="$delete-mml-ns"/>
  </xsl:template>
  
  <xsl:variable name="delete-mml-ns">
    <xsl:apply-templates select="$apply-unwrap-mml" mode="delete-mml-ns"/>
  </xsl:variable>
  
  <xsl:variable name="apply-unwrap-mml">
    <xsl:apply-templates select="$attach-mml-ns" mode="apply-unwrap-mml"/>
  </xsl:variable>
  
  <xsl:variable name="attach-mml-ns">
    <xsl:apply-templates select="/" mode="attach-mml-ns"/>
  </xsl:variable>
  
  <!-- identity template -->
  
  <xsl:template match="*|@*|processing-instruction()|comment()" 
                mode="attach-mml-ns apply-unwrap-mml delete-mml-ns" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
