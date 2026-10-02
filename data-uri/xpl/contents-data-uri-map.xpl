<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:tr="http://transpect.io"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                type="tr:contents-data-uri-map"
                version="3.1">

  <p:input port="contents" sequence="true" content-types="any"/>

  <p:output port="result" content-types="application/json" serialization="map{'escape-solidus': false()}"/>

  <p:option name="fail-on-error" as="xs:boolean" select="true()"/>

  <p:for-each name="files">
    <p:variable name="base-uri" as="xs:string" select="p:urify(p:document-property(., 'base-uri'))"/>
    <p:encode/>
    <p:add-attribute attribute-name="base-uri" attribute-value="{$base-uri}"/>
  </p:for-each>

  <p:wrap-sequence wrapper="files"/>

  <p:xslt>
    <p:with-input port="stylesheet">
      <p:inline expand-text="false">
        <xsl:stylesheet
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:map="http://www.w3.org/2005/xpath-functions/map"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            version="3.0">
          <xsl:param name="fail-on-error" as="xs:boolean"/>
          <xsl:output method="json"/>

          <xsl:template match="/">
            <xsl:variable name="files" as="element(file)*">
              <xsl:for-each-group select="/files/c:data" group-by="@base-uri">
                <file>
                  <xsl:copy-of select="@*"/>
                  <xsl:if test="count(current-group()) gt 1">
                    <xsl:message terminate="{if ($fail-on-error) then 'yes' else 'no'}" 
                      select="'tr:contents-data-uri-map: Duplicate base URI: ' || current-grouping-key()"/>
                    <xsl:attribute name="duplicates" select="'true'"/>
                  </xsl:if>
                  <xsl:attribute name="data-uri" select="'data:' || @content-type || ';base64,' || ."/>
                </file>
              </xsl:for-each-group>
            </xsl:variable>
            <xsl:sequence select="if ($files/@duplicate)
                                  then map{}
                                  else map:merge(
                                    $files ! map:entry(string(@base-uri), string(@data-uri))
                                  )"/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:with-input>
    <p:with-option name="parameters" select="map{xs:QName('fail-on-error'): $fail-on-error}"/>
  </p:xslt>

</p:declare-step>
