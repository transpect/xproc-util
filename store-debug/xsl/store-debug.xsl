<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0">
  <xsl:param name="pipeline-step" as="xs:string"/>
  <xsl:param name="storage-base-uri" as="xs:string"/>
  <xsl:param name="default-storage-base-uri" as="xs:string"/>
  <xsl:param name="extension" as="xs:string"/>
  <xsl:variable name="without-query" as="xs:string" select="replace($storage-base-uri, '^(.+)\?.*$', '$1')"/>
  <xsl:template name="main">
    <xsl:variable name="base" as="xs:string" select="
        string(
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
<!--            use saxon generated distinction values in case there are multiple documents without a proper xml:base attribute -->
            <xsl:variable name="saxon-distinction" select="replace(tokenize(current-grouping-key(), '\?')[2][last()], '[&amp;=#\+%;]', '_')" as="xs:string"/>
            <xsl:variable name="notdir" select="replace(current-grouping-key(), '^.*/', '')" as="xs:string"/>
            <xsl:variable name="without-ext" as="xs:string" select="
                if ($notdir = '')
                then
                  string-join(('', 'filename', 'unknown', string(position())), '__')
                else
                  string-join((replace($notdir, '^(.+)\.(.+)$', '$1'), $saxon-distinction), '_')"/>
            <xsl:variable name="ext" as="xs:string" select="
                if (normalize-space($extension))
                then
                  $extension
                else
                  if (matches($notdir, '^(.+)\.(.+)$'))
                  then
                    replace($notdir, '^(.+)\.(.+)$', '$2')
                  else
                    'xml'"/>
            <!--<xsl:message select="'RRRRRRRRRRRRRRRRR notdir:', $notdir, ' without-ext:', $without-ext, ' ext:', $ext, ', base-uri(/*):', base-uri(/*), ' base-uri():', base-uri()"></xsl:message>-->
            <xsl:for-each select="current-group()">
              <xsl:variable name="href" as="xs:string"
                select="concat($base, '/', string-join(($without-ext, string(position()[. gt 1])[normalize-space()], $ext), '.'))"/>
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