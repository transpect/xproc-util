<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io" 
  version="1.0" 
  name="unescape-uri" 
  type="tr:unescape-uri">

  <p:option name="uri"/>
  
  <p:output port="result" primary="true">
    <p:documentation>c:result element with the %HH-unescaped string as text content.</p:documentation>
  </p:output>
  
  <p:xslt name="unescape" template-name="main">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-param name="uri" select="$uri"/>
    <p:input port="stylesheet">
      <p:document href="../xsl/unescape-for-os-path.xsl"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>
