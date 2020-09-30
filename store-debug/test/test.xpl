<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0" exclude-inline-prefixes="#all">
  <p:documentation>Invocation from XProc: Don’t supply a value for $collection-uri. 
    Invocation from Saxon: Pass
    collection-uri=file:///path/to/debug-dir/schubi/dubi.catalog.xml to test.xsl.
    This is the catalog file that a previous XProc invocation of test.xpl created. 
    The catalog file refers to the stored debug files. 
    If you need non-indented debug files, append ?indent=false to debug-dir-uri (that is,
    the URI that tr:store-debug calls base-uri).</p:documentation>
  <p:input port="source" sequence="true">
    <p:inline>
      <doc>Hello world!</doc>
    </p:inline>
    <p:inline>
      <hurz>schnurz</hurz>
    </p:inline>
  </p:input>
  <p:output port="result" sequence="true"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  <p:option name="debug" required="false" select="'yes'"/>
  
  <p:import href="../xpl/store-debug.xpl"/>
  
  <tr:store-debug pipeline-step="schubi/dubi" extension="xml">
    <p:with-option name="base-uri" select="$debug-dir-uri"><p:empty/></p:with-option>
    <p:with-option name="active" select="$debug"><p:empty/></p:with-option>
  </tr:store-debug>
  
  <p:xslt template-name="main">
    <p:input port="stylesheet">
      <p:document href="test.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  <p:identity/>
</p:declare-step>