<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:tr="http://transpect.io"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                name="test-data-uri-map"
                version="3.1">

  <p:documentation>Create a map c:entry/@name → data: URI for archive manifest entries. The data: URIs will be computed
  from the archive members whose base URI is c:entry/@href. 
  Unlike in this example test-contents-data-uri-map.sh, where this pipeline is applied to dir.zip,
  the part after the .zip base URI in c:entry/@href isn’t necessarily equal to @name. If the zip manifest has been
  altered in order to rename or move entries, the @name attributes will be altered but the @href attributes will stay
  the same, and these @href attributes will be equal to the base URIs of the archive content file. 
  In order to determine equality, p:urify() normalization of the base URIs and/or the c:entry/@href attributes 
  may be necessary. For example in XML Calabash 3, the base URIs are file:/path/… while the c:entry/@href attributes 
  are file:///path/…</p:documentation>

  <p:import href="../xpl/contents-data-uri-map.xpl"/>
  <p:import href="../xpl/manifest-data-uri-map.xpl"/>
    
  <p:input port="source" primary="true" content-types="application/zip"/>

  <p:output port="contents-map" content-types="application/json" pipe="result@contents-data-uri-map"
    serialization="map{'escape-solidus': false(), 'indent': true()}"/>
  <p:output port="result" primary="true" content-types="application/json" 
    serialization="map{'escape-solidus': false(), 'indent': true()}"/>

  <p:option name="name-keys-relative-to" as="xs:string" select="'index.html'"/>
  
  <p:unarchive name="unarchive">
    <p:with-input pipe="source@test-data-uri-map"/>
  </p:unarchive>
  
  <tr:contents-data-uri-map name="contents-data-uri-map"/>
  
  <p:archive-manifest name="archive-manifest">
    <p:with-input port="source" pipe="source@test-data-uri-map"/>
  </p:archive-manifest>
  
  <tr:manifest-data-uri-map name-keys-relative-to="{$name-keys-relative-to}">
    <p:with-input port="data-uris" pipe="result@contents-data-uri-map"/>
  </tr:manifest-data-uri-map>

</p:declare-step>
