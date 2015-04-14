<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:idml2xml  = "http://www.le-tex.de/namespace/idml2xml"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:html2hub="http://www.le-tex.de/namespace/html2hub"
  xmlns:ttt="http://www.le-tex.de/namespace/tokenized-to-tree"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:hub2app="http://www.le-tex.de/namespace/hub2app"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="xslt-mode"
  type="tr:xslt-mode">
    
  <p:option name="mode" required="true">
    <p:documentation>Please be aware that, as per the spec, the initial mode option of
    p:xslt must be a QName. You cannot invoke the #default mode here.
    And if you’re using namespace-prefixed modes, you’ll have to declare the namespaces
    here in this .xpl file. This is admittedly unfortunate.</p:documentation>
  </p:option>
  <p:option name="prefix" required="false" select="''"/>
  <p:option name="msg" required="false" select="'no'"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="true"/>
  <p:option name="hub-version" required="false" select="''"/>
  
  <p:input port="source" primary="true" sequence="true"/>
  <p:input port="stylesheet"/>
  <p:input port="models" sequence="true">
    <p:empty/>
    <p:documentation>see prepend-xml-model.xpl</p:documentation>
  </p:input>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" sequence="true"/>
  <p:output port="secondary" sequence="true">
    <p:pipe port="secondary" step="xslt"/>
  </p:output>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-xml-model.xpl" />
  
  <p:variable name="debug-file-name" select="concat($prefix, '.', replace($mode, ':', '_'))"><p:empty/></p:variable>
  
  <p:choose>
    <p:xpath-context><p:empty/></p:xpath-context>
    <p:when test="$msg = 'yes'">
      <cx:message>
        <p:with-option name="message" 
          select="concat('Mode: ', $mode, 
                         if ($prefix and $debug = 'yes') 
                         then concat('  debugs into ', $debug-dir-uri, '/', replace($debug-file-name, '//+', '/'), '.xml') 
                         else ''
                        )"><p:empty/></p:with-option>
      </cx:message>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:xslt name="xslt">
    <p:with-option name="initial-mode" select="$mode">
      <p:pipe port="stylesheet" step="xslt-mode"/>
    </p:with-option>
    <p:input port="parameters">
      <p:pipe port="parameters" step="xslt-mode"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="xslt-mode"/>
    </p:input>
    <p:with-param name="debug" select="$debug"><p:empty/></p:with-param>
  </p:xslt>

  <p:sink/>

  <p:for-each>
    <p:iteration-source>
      <p:pipe step="xslt" port="secondary"/>
    </p:iteration-source>
    <p:store indent="true" omit-xml-declaration="false">
      <p:with-option name="href" select="base-uri()"/>
    </p:store>
  </p:for-each>
  
  <tr:prepend-xml-model>
    <p:input port="source">
      <p:pipe port="result" step="xslt"/>
    </p:input>
    <p:input port="models">
      <p:pipe port="models" step="xslt-mode"/>
    </p:input>
    <p:with-option name="hub-version" select="$hub-version"/>
  </tr:prepend-xml-model>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="$debug-file-name"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
</p:declare-step>