<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  exclude-result-prefixes="xs tr"
  version="2.0">
  
  <xsl:param name="href"/>
  
  <!--  * please see RFC 3986 for details
        * https://tools.ietf.org/html/rfc3986 
        * -->
  
  <xsl:variable name="scheme-regex" select="'([\w\-\.]+):/?/?'" as="xs:string"/>
  <xsl:variable name="user-regex" select="'([\w\-_\.]+@)?'" as="xs:string"/>
  <xsl:variable name="host-regex" select="'([\w\-_\.]+)'" as="xs:string"/>
  <xsl:variable name="port-regex" select="'(:\d+)?'" as="xs:string"/>
  <xsl:variable name="authority-regex" select="concat('(', $user-regex, '', $host-regex, $port-regex, ')')" as="xs:string"/>
  <xsl:variable name="path-regex" select="'(/[\w\-_\./]+)?'" as="xs:string"/>
  <xsl:variable name="query-regex" select="'(\?[\w\-_\.&amp;=]+)?'" as="xs:string"/>
  <xsl:variable name="fragment-regex" select="'(#[\w\-_\.]+)?'" as="xs:string"/>
  
  <xsl:variable name="uri-regex" select="concat('^', 
                                                $scheme-regex, 
                                                $user-regex, 
                                                $host-regex, 
                                                $port-regex, 
                                                $path-regex, 
                                                $query-regex, 
                                                $fragment-regex)" as="xs:string"/>
  
  <xsl:template name="main">
    <xsl:variable name="uri-components" select="tr:decompose-uri($href)"/>
    <c:param-set>
      <xsl:attribute name="href" select="$href"/>
      <xsl:for-each select="$uri-components[normalize-space(.)]">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:for-each select="tokenize($uri-components[local-name() eq 'query'], '&amp;')">
        <xsl:variable name="key-value" select="tokenize(., '=')"/>
        <c:param name="{$key-value[1]}" value="{$key-value[2]}"/>
      </xsl:for-each>
    </c:param-set>
  </xsl:template>
  
  <xsl:function name="tr:decompose-uri" as="attribute()+">
    <xsl:param name="href"/>
    <xsl:analyze-string select="$href" regex="{$uri-regex}">
      <xsl:matching-substring>
        <xsl:attribute name="scheme" select="regex-group(1)"/>
        <xsl:attribute name="user" select="replace(regex-group(2), '@$', '')"/>
        <xsl:attribute name="host" select="regex-group(3)"/>
        <xsl:attribute name="port" select="replace(regex-group(4), '^:', '')"/>
        <xsl:attribute name="path" select="regex-group(5)"/>
        <xsl:attribute name="query" select="replace(regex-group(6), '^\?', '')"/>
        <xsl:attribute name="fragment" select="replace(regex-group(7), '^#', '')"/>
        <xsl:if test="regex-group(2) and regex-group(3) and regex-group(4)">
          <xsl:attribute name="authority" select="concat(regex-group(2), regex-group(3), regex-group(4))"/>
        </xsl:if>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>
</xsl:stylesheet>
