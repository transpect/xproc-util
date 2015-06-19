<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <xsl:import href="http://transpect.io/xslt-util/resolve-uri/xsl/resolve-uri.xsl"/>
  
  <xsl:param name="uri" as="xs:string?"/>
  
  <xsl:template name="resolve">
    <result>
      <xsl:if test="$uri">
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="matches($uri, '^/[^/]')">
              <xsl:sequence select="tr:uri-composer(concat('file:', $uri), '')"/>
            </xsl:when>
            <xsl:when test="matches($uri, '^[a-z]+:', 'i')">
              <xsl:sequence select="tr:uri-composer($uri, '')"/>
            </xsl:when>
            <xsl:when test="matches($uri, '^//')">
              <xsl:sequence select="tr:uri-composer($uri, '')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$uri"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute> 
      </xsl:if>
    </result>
  </xsl:template>
</xsl:stylesheet>