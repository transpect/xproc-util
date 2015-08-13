<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:tr="http://transpect.io"
  version="1.0" 
  name="insert-srcpaths"
  type="tr:insert-srcpaths">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>tr:insert-srcpaths</h1>
    <p>This step inserts the XPath location of any element as attribute.</p>
  </p:documentation>

  <p:input port="source"/>
  <p:output port="result"/>

  <p:option name="insert-srcpaths" select="'yes'"/>
  <p:option name="exclude-elements" select="''"/>       <!-- white-space separated list of element names"/> -->  
  <p:option name="exclude-descendants" select="'yes'"/> <!-- whether the descendants of the excluded elements should be processed -->
  
  <p:xslt>
    <p:with-param name="insert-srcpaths" select="$insert-srcpaths"/>
    <p:with-param name="exclude-elements" select="$exclude-elements"/>
    <p:with-param name="exclude-descendants" select="$exclude-descendants"/>
    <p:input port="stylesheet">
      <p:document href="../xsl/insert-srcpaths.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>