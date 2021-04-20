<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:hub = "http://transpect.io/hub"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="tr hub xs">

  <!-- input: hub document with zero or more @fileref´s
       output: a sequence of c:entry elements
  -->

  <xsl:param name="retain-subpaths" select="'no'" as="xs:string"/>
  <xsl:param name="change-uri-new-subpath" select="''" as="xs:string"/>
  <xsl:param name="target-dir-uri" as="xs:string"/>
  <xsl:param name="fail-on-error" as="xs:string" select="'false'"/>
  <xsl:param name="fileref-attribute-name-regex" select="'^fileref$'" as="xs:string"/>
  <xsl:param name="fileref-attribute-value-regex" select="'^.+$'" as="xs:string"/>
  <xsl:param name="fileref-hosting-element-name-regex" select="'^(audiodata|imagedata|textdata|videodata)$'" as="xs:string"/>

  <xsl:variable name="source-dir-uri" as="xs:string"
    select="replace(
              /*/*:info/*:keywordset[@role eq 'hub']/*:keyword[@role eq 'source-dir-uri'], 
              '^(file:)/+', 
              '$1///'
            )"/>

  <xsl:template name="create-entries-from-hub">
    <xsl:variable name="hub-filerefs" 
      select="(//*[matches(name(), $fileref-hosting-element-name-regex)]
                  /@*[matches(name(), $fileref-attribute-name-regex)]
                     [matches(., $fileref-attribute-value-regex)])" as="attribute(*)*"/>
    <c:copy-files>
      <xsl:attribute name="xml:base" select="base-uri(/*)"/>
      <xsl:for-each-group select="$hub-filerefs[. ne '']" group-by="tr:target-path(., $target-dir-uri)">
        <xsl:sort select="." order="ascending"/>
        <xsl:variable name="source-files" as="xs:string+" select="current-group()"/>
        <xsl:if test="count(distinct-values($source-files)) gt 1">
          <xsl:message terminate="{('yes'[$fail-on-error = 'true'], 'no')[1]}">ERROR in copy-files.xpl: Multiple source files <xsl:value-of 
            select="distinct-values($source-files)" separator=", "/> will be copied to a single target: <xsl:value-of 
              select="current-grouping-key()"/></xsl:message>
        </xsl:if>
        <c:entry>
          <xsl:attribute name="href" select="tr:expand-container-fileref(.)"/>
          <xsl:attribute name="target" select="current-grouping-key()"/>
        </c:entry>
      </xsl:for-each-group>
    </c:copy-files>
  </xsl:template>
  
  <xsl:function name="tr:target-path" as="xs:string">
    <xsl:param name="_fileref" as="attribute(*)"/>
    <xsl:param name="_target-dir-uri" as="xs:string"/>
    <xsl:sequence select="(
                            $_fileref/../@hub:target-fileref[starts-with(., 'file:/')],
                            tr:change-fileref(($_fileref/../@hub:target-fileref, $_fileref)[1], $target-dir-uri)
                          )[1]"/>
  </xsl:function>

  <xsl:function name="tr:expand-container-fileref" as="xs:string">
    <xsl:param name="fileref" as="xs:string"/>
    <xsl:sequence select="replace($fileref, '^container[:]', $source-dir-uri)"/>
  </xsl:function>

  <xsl:function name="tr:change-fileref" as="xs:string">
    <xsl:param name="fileref" as="xs:string"/>
    <xsl:param name="prefix-path" as="xs:string?"/>
    <xsl:variable name="container-subdir" as="xs:string"
      select="replace($fileref, '^container[:]', '')"/>
    <xsl:variable name="normalized-uri" as="xs:string"
      select="tr:expand-container-fileref($fileref)"/>
    <xsl:choose>
      <xsl:when test="$retain-subpaths eq 'yes'">
        <xsl:value-of select="string-join(
                                (
                                  $change-uri-new-subpath, 
                                  substring-after($normalized-uri, $source-dir-uri)
                                )[ . ne ''], 
                                '/'
                              )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string-join(
                                (
                                  $prefix-path, 
                                  $change-uri-new-subpath, 
                                  tokenize($normalized-uri, '/')[last()]
                                )[. ne ''], 
                                '/'
                              )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="*[matches(name(), $fileref-hosting-element-name-regex)]
                        [empty(@hub:target-fileref)]
                        /@*[matches(name(), $fileref-attribute-name-regex)]
                           [matches(., $fileref-attribute-value-regex)]" mode="change-uri">
    <xsl:attribute name="{name()}" select="tr:change-fileref(., '')"/>
  </xsl:template>

  <xsl:template match="node()|@*" mode="change-uri" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"     mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>