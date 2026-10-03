<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:tr="http://transpect.io"
                type="tr:manifest-data-uri-map"
                name="manifest-data-uri-map"
                version="3.1">

  <p:input port="manifest" primary="true" content-types="application/xml"/>

  <p:input port="data-uris" content-types="application/json"/>
  
  <p:input port="entry-name-to-map-key">
    <p:document href="../xsl/entry-name-to-map-key.xsl"/>
  </p:input>

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
    <p:with-input port="stylesheet" pipe="entry-name-to-map-key@manifest-data-uri-map"/>
  </p:xslt>

</p:declare-step>
