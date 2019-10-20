<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" version="1.0" type="tr:load-sources"
  name="load-sources-decl">
  <p:documentation>Documents identified by their base URIs should be selected from the documents on the source port. 
    The selected documents are then passed to the result port. If there is no matching document on the source port 
    for a given URI, the document should instead be loaded from the location specified by the base URI.</p:documentation>
  <p:input port="source" sequence="true" primary="true">
    <p:empty/>
  </p:input>
  <p:output port="result" sequence="true">
    <p:pipe port="secondary" step="load-sources-xsl2"/>
  </p:output>
  <p:option name="uris">
    <p:documentation>Space-separated list of URIs</p:documentation>
  </p:option>
  <p:xslt name="load-sources-xsl1" template-name="main">
    <p:with-param name="uris" select="$uris">
      <p:empty/>
    </p:with-param>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:param name="uris" as="xs:string"/>
          <xsl:template name="main">
            <xsl:for-each select="distinct-values(tokenize($uris, '\s+'))">
              <xsl:variable name="uri" as="xs:string" select="."/>
              <xsl:choose>
                <xsl:when test="exists(collection()[base-uri() = $uri])">
                  <xsl:result-document href="{$uri}.new">
                    <xsl:sequence select="collection()[base-uri() = $uri]"/>
                  </xsl:result-document>
                  <xsl:message>Loading <xsl:value-of select="$uri"/> from source port</xsl:message>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="doc-available($uri)">
                    <xsl:result-document href="{$uri}.new">
                      <xsl:sequence select="doc($uri)"/>
                    </xsl:result-document>
                    <xsl:message>Loading <xsl:value-of select="$uri"/> from disk</xsl:message>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <nodoc/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  <p:sink name="sink1"/>
  <p:xslt name="load-sources-xsl2" template-name="main">
    <p:input port="source">
      <p:pipe port="secondary" step="load-sources-xsl1"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:template name="main">
            <xsl:for-each select="collection()">
              <xsl:variable name="uri" as="xs:string" select="replace(base-uri(), '\.new$', '')"/>
              <xsl:result-document href="{$uri}">
                <xsl:sequence select="."/>
              </xsl:result-document>
            </xsl:for-each>
            <nodoc/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  <p:sink name="sink2"/>
</p:declare-step>
