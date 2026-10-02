<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:tr="http://transpect.io"
                type="tr:manifest-data-uri-map"
                name="manifest-data-uri-map"
                version="3.1">

  <p:input port="manifest" primary="true" content-types="application/xml"/>

  <p:input port="data-uris" content-types="application/json"/>

  <p:output port="result" content-types="application/json" serialization="map{'escape-solidus': false()}"/>

  <!-- Normalize manifest href values before doing the join. -->
  <p:viewport match="/c:entry" name="normalize-manifest-uris">
    <p:add-attribute attribute-name="href" attribute-value="{p:urify(/c:entry/@href)}"/>
  </p:viewport>

  <p:cast-content-type content-type="application/xml" name="data-uris-xml">
    <p:with-input pipe="data-uris@manifest-data-uri-map"/>
  </p:cast-content-type>

  <p:wrap-sequence name="inputs" wrapper="inputs">
    <p:with-input port="source" pipe="result@normalize-manifest-uris result@data-uris-xml"/>
  </p:wrap-sequence>

  <p:xslt>
    <p:with-input port="source" pipe="result@inputs"/>
    <p:with-input port="stylesheet">
      <p:inline>
        <xsl:stylesheet
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:fn="http://www.w3.org/2005/xpath-functions"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:map="http://www.w3.org/2005/xpath-functions/map"
            version="3.0">
          <xsl:output method="json"/>

          <xsl:template match="/">
            <xsl:variable name="manifest-entries" as="element(c:entry)*" select="/inputs/c:archive/c:entry"/>
            <xsl:variable name="data-uris" as="element(fn:string)*" select="/inputs/fn:map/fn:string"/>

            <xsl:sequence select="
              map:merge(
                for $e in $manifest-entries[@href = $data-uris/@key] return
                map:entry(
                  string($e/@name),
                  string($data-uris[@key = $e/@href])
                )
              )"/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:with-input>
  </p:xslt>

</p:declare-step>
