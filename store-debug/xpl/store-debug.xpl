<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"    
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io" 
  version="1.0"
  type="tr:store-debug" 
  name="store-debug">
  
  <p:input port="source" sequence="true"/>
  <p:output port="result" sequence="true"/>
  
  <p:option name="active" required="false" select="'no'"/>
  <p:option name="pipeline-step" required="true"/>
  <p:option name="default-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="base-uri" required="false" select="''"/>
  <p:option name="extension" required="false" select="''"/>
  <p:option name="indent" required="false" select="'true'">
    <p:documentation>Indentation may also be set by query string (indent=true|false after a question mark in $default-uri).
    The same applies to $active, whether it should write debug files at all. 
    The parameters may be separated by any character, not necessarily '&amp;' or ';'.
    The URI query parameters have precedence over $base-uri and $active, respectively.
    Query parameters may only be 'true' or 'false' while $active may also be 'yes' for historical reasons.
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:variable name="actually-active" select="if (matches($base-uri, '^.+\?.*active=(true|false).*$'))
                                             then replace($base-uri, '^.+\?.*active=(true|false).*$', '$1')
                                             else $active">
    <p:empty/>
  </p:variable>  
  <p:choose>
    <p:when test="$actually-active = ('yes', 'true')">
      <p:xpath-context><p:empty/></p:xpath-context>
      <p:variable name="actual-indent" select="if (matches($base-uri, '^.+\?.*indent=(true|false).*$'))
                                               then replace($base-uri, '^.+\?.*indent=(true|false).*$', '$1')
                                               else $indent">
        <p:empty/>
      </p:variable>
      <p:xslt name="catalog-and-storage-uris" template-name="main">
        <p:with-param name="storage-base-uri" select="$base-uri"><p:empty/></p:with-param>
        <p:with-param name="default-storage-base-uri" select="$default-uri"><p:empty/></p:with-param>
        <p:with-param name="extension" select="$extension"><p:empty/></p:with-param>
        <p:with-param name="pipeline-step" select="$pipeline-step"><p:empty/></p:with-param>
        <p:input port="parameters"><p:empty/></p:input>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
              <xsl:param name="pipeline-step" as="xs:string"/>
              <xsl:param name="storage-base-uri" as="xs:string"/>
              <xsl:param name="default-storage-base-uri" as="xs:string"/>
              <xsl:param name="extension" as="xs:string"/>
              <xsl:variable name="without-query" as="xs:string" select="replace($storage-base-uri, '^(.+)\?.*$', '$1')"/>
              <xsl:template name="main">
                <xsl:variable name="base" as="xs:string"
                  select="string(
                            resolve-uri(
                              concat(
                                replace(
                                  ($without-query[normalize-space()], $default-storage-base-uri)[1],
                                  '^(.*?)/+$',
                                  '$1'
                                ), '/', $pipeline-step
                              )
                            )
                          )"/>
                <collection>
                  <xsl:attribute name="xml:base" select="concat($base, '.catalog.xml')"/>
                  <xsl:choose>
                    <xsl:when test="count(collection()/*) = 0"/>
                    <xsl:when test="count(collection()/*) = 1">
                      <xsl:variable name="href" as="xs:string"
                        select="concat($base, '.', ($extension[normalize-space()], 'xml')[1])"/>
                      <doc href="{$href}"/>
                      <xsl:result-document href="{$href}">
                        <xsl:sequence select="collection()"/>
                      </xsl:result-document>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each-group select="collection()[*]" group-by="(base-uri(/*), base-uri(), '')[1]">
                        <xsl:variable name="notdir" select="replace(current-grouping-key(), '^.*/', '')" as="xs:string"/>
                        <xsl:variable name="without-ext" as="xs:string" select="replace($notdir, '^(.+)\.(.+)$', '$1')"/>
                        <xsl:variable name="ext" as="xs:string?" 
                          select="if (normalize-space($extension)) 
                                  then $extension 
                                  else if (matches($notdir, '^(.+)\.(.+)$')) 
                                       then replace($notdir, '^(.+)\.(.+)$', '$2')
                                       else ()"/>
                        <xsl:for-each select="current-group()">
                          <xsl:variable name="href" as="xs:string"
                            select="concat($base, '/', string-join(($without-ext, position()[. gt 1], $ext), '.'))"/>
                          <doc href="{$href}"/>
                          <xsl:result-document href="{$href}">
                            <xsl:sequence select="."/>
                          </xsl:result-document>
                        </xsl:for-each>
                      </xsl:for-each-group>    
                    </xsl:otherwise>
                  </xsl:choose>
                </collection>
              </xsl:template>
            </xsl:stylesheet>
          </p:inline>
        </p:input>
      </p:xslt>
      
      <p:sink name="sink0"/>
      
      <p:count>
        <p:input port="source">
          <p:pipe port="secondary" step="catalog-and-storage-uris"/>
        </p:input>
      </p:count>
      
      <p:choose>
        <p:when test=". > 0">
          <p:identity>
            <p:input port="source">
              <p:pipe port="result" step="catalog-and-storage-uris"/>
            </p:input>
          </p:identity>
          <p:store name="store-catalog" indent="true" omit-xml-declaration="false">
            <p:with-option name="href" select="/collection/@xml:base">
              <p:pipe port="result" step="catalog-and-storage-uris"/>
            </p:with-option>
          </p:store>
        </p:when>
        <p:otherwise>
          <p:sink name="sink1"/>
        </p:otherwise>
      </p:choose>
      
      <p:for-each name="store-iteration">
        <p:iteration-source>
          <p:pipe port="secondary" step="catalog-and-storage-uris"/>
        </p:iteration-source>
        <p:store omit-xml-declaration="false">
          <p:with-option name="indent" select="$actual-indent"/>
          <p:with-option name="href" select="base-uri()"/>
          <p:with-option name="method" select="if (matches(base-uri(), 'html$')) then 'xhtml' else 'xml'"/>
        </p:store>
      </p:for-each>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="store-debug"/>
        </p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>