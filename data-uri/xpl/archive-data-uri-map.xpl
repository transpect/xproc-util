<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:tr="http://transpect.io"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                type="tr:archive-data-uri-map"
                name="archive-data-uri-map"
                version="3.1">

  <p:documentation>Create a map c:entry/@name → data: URI for archive manifest entries. The data: URIs will be computed
  from the archive members whose base URI is c:entry/@href.</p:documentation>

  <p:import href="contents-data-uri-map.xpl"/>
  <p:import href="manifest-data-uri-map.xpl"/>
    
  <p:input port="contents" primary="true" content-types="any">
    <p:documentation>The result of p:unarchive</p:documentation>
  </p:input>
  
  <p:input port="manifest">
    <p:documentation>The result of p:archive-manifest</p:documentation>
  </p:input>

  <p:output port="result" primary="true" content-types="application/json" 
    serialization="map{'escape-solidus': false(), 'indent': true()}"/>

  <tr:contents-data-uri-map name="contents-data-uri-map"/>
    
  <tr:manifest-data-uri-map>
    <p:with-input port="manifest" pipe="manifest@archive-data-uri-map"/>
    <p:with-input port="data-uris" pipe="result@contents-data-uri-map"/>
  </tr:manifest-data-uri-map>

</p:declare-step>
