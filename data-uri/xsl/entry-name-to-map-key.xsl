<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs map c tr"
  version="3.0">
  
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <xsl:output method="json"/>
  
  <xsl:param name="name-keys-relative-to" as="xs:string" select="'index.html'"/>
  
  <xsl:template match="@name" as="xs:string" mode="tr:entry-name-to-map-key">
    <xsl:sequence 
      select="tr:uri-to-relative-path('file:///bogo.zip/' || $name-keys-relative-to, 'file:///bogo.zip/' || .)"/>
  </xsl:template>
  
  <xsl:function name="tr:entry-name-to-map-key" as="xs:string">
    <xsl:param name="name-att" as="attribute(*)"/>
    <xsl:apply-templates select="$name-att" mode="tr:entry-name-to-map-key"/>
  </xsl:function>
  
  <xsl:template match="/">
    <xsl:variable name="manifest-entries" as="element(c:entry)*" select="/inputs/c:archive/c:entry"/>
    <xsl:variable name="data-uris" as="element(fn:string)*" select="/inputs/fn:map/fn:string"/>
    <xsl:sequence select="map:merge(
                            for $e in $manifest-entries[@href = $data-uris/@key] return
                            map:entry(
                              tr:entry-name-to-map-key($e/@name),
                              string($data-uris[@key = $e/@href])
                            )
                          )"/>
  </xsl:template>
</xsl:stylesheet>