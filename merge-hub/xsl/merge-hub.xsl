<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:s="http://purl.oclc.org/dsdl/schematron" 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 
  xmlns:hub="http://www.le-tex.de/namespace/hub" 
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:csstmp="http://www.le-tex.de/namespace/csstmp"  
  xmlns:functx="http://www.functx.com"
  exclude-result-prefixes="xs" 
  xpath-default-namespace="http://docbook.org/ns/docbook" 
  version="2.0">
  
  <!-- TO-DO: rename paths -->

  <!-- used to insert sourcepaths -->
  <xsl:import href="http://www.functx.com/XML_Elements_and_Attributes/XML_Document_Structure/path-to-node-with-pos.xsl"/>
  
  <xsl:param name="value-separator" select="'~~~'"/>

  <!-- identity template -->
  <xsl:template match="@* | *" mode="merge-hub">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/cx:document" mode="merge-hub">
    <hub>
      <xsl:apply-templates mode="#current"/>
    </hub>
  </xsl:template>

  <xsl:template match="hub" mode="merge-hub">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- match first css:rules element -->
  <xsl:template match="/cx:document/hub[1]/info/css:rules" mode="merge-hub">
    <xsl:copy>
      <!-- group CSS rules by style name -->
      <xsl:for-each-group select="/cx:document//css:rules/css:rule" group-by="@name">
        <xsl:variable name="style-name" select="current-grouping-key()" as="xs:string"/>

        <!-- group CSS properties by property name, e.g. css:font-size -->
        <xsl:copy>
          <xsl:apply-templates select="@*[namespace-uri() ne 'http://www.w3.org/1996/css']" mode="#current"/>
          
          <xsl:for-each-group select="current-group()/@css:*" group-by="name()">
            <xsl:variable name="css-distinct-values" select="distinct-values(current-group())"/>
            <!-- if a CSS property differs among one style, use the first value and create a Schematron Message -->

            <xsl:choose>
              <xsl:when test="count($css-distinct-values) gt 1">

                <!-- message for terminal output and SVRL -->
                <xsl:variable name="message" select="concat('[WARNING] merge-hub.xsl: Style ', $style-name, ' differs in ', name(), ': ', string-join($css-distinct-values, ', '), ' (using first value)')"/>
                <xsl:message select="$message"/>

                <!-- use only first attribute value -->
                <xsl:attribute name="{name()}" select="$css-distinct-values[1]"/>

                <!-- write other values separated in a single attribute to process them later -->
                <xsl:attribute name="{concat('csstmp:', local-name())}" select="string-join($css-distinct-values, $value-separator)"/>

              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="{name()}" select="$css-distinct-values"/>
              </xsl:otherwise>
            </xsl:choose>

          </xsl:for-each-group>

        </xsl:copy>

      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <!-- match other css:rules elements. this templates has got lower priority -->
  <xsl:template match="/cx:document/hub[position() ne 1]/info/css:rules" mode="merge-hub"/>

  <xsl:template match="/" mode="generate-report">
    <svrl:schematron-output>
      
      <svrl:active-pattern id="ambiguous-css-property" name="ambiguous-css-property"/>
      
      <xsl:apply-templates select="//css:rule[@csstmp:*]" mode="generate-report"/>
    </svrl:schematron-output> 
  </xsl:template>

  <xsl:template match="*[@csstmp:*]" mode="generate-report">
    <xsl:variable name="srcpath" select="functx:path-to-node-with-pos(.)" as="xs:string"/>
    <xsl:variable name="style-name" select="@name" as="xs:string"/>
    <xsl:for-each select="@csstmp:*">
      <svrl:fired-rule context="{$srcpath}"/>
      <svrl:failed-assert 
        test="css-property" id="merge-hub-style-ambiguosity"
        location="{$srcpath}">
        <svrl:text>
          <s:span class="srcpath"><xsl:value-of select="$srcpath"/></s:span>
          <s:span class="css"><xsl:value-of select="concat('Style ''', $style-name ,''' with ambiguous CSS property ''', local-name(), '''. Multiple values (', string-join(tokenize(., $value-separator), ', '), ') defined. Using first value.')"/></s:span>
        </svrl:text>
      </svrl:failed-assert>  
    </xsl:for-each>
    
  </xsl:template>

</xsl:stylesheet>