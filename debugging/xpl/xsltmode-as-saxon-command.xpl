<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://transpect.io"
  name="xsltmode-as-saxon-command"
  type="tr:xsltmode-as-saxon-command">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>The purpose of this XProc pipeline is to create saxon call of the entire xsltmode-conversion runable in a shell. 
       With all params and optionally a saxon configuration plus collection file.</p>
    <p>All output documents are written to disc. The executable file + invocation call is messaged to console.</p>
  </p:documentation>
  
  <p:option name="mode" required="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Mode name to process/debug the source document. For example: <kbd>hub:hierarchy</kbd></p>
      <p>You have to add your individual namespace-URI (search for clark-mode-qname here) when your mode prefix is messaged as unknown.</p>
    </p:documentation>
  </p:option>
  
  <p:option name="saxon-call-base-uri" required="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>URI of a (debug) file. Used to write the executable <kbd>{$saxon-call-base-uri}.sh</kbd> and all other.</p>
      <p>Output of the saxon conversion call is: <kbd>{$saxon-call-base-uri}.output</kbd></p>
    </p:documentation>
  </p:option>
  
  <p:option name="saxon-executable" required="false" select="'saxon'">
    <p:documentation>Path to saxon executable file. For example 'saxon' or 'saxon/saxon.sh'.</p:documentation>
  </p:option>
  
  <p:option name="run-immediately" required="false" select="'no'">
    <p:documentation>Execute the built saxon command with p:exec builtin step.</p:documentation>
  </p:option>
    
  <p:input port="source" primary="true" sequence="true">
    <p:documentation>The source/input document(s) to process.</p:documentation>
  </p:input>
  
  <p:input port="stylesheet" sequence="false">
    <p:documentation>The XSLT file.</p:documentation>
  </p:input>
  
  <p:input port="xslt-params" sequence="true">
    <p:documentation>A (consodilated) file of all XSLT parameters (c:param-set) for the stylesheet.</p:documentation>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="saxon-call"/>
    <p:documentation>The saxon call as XML for reuse.</p:documentation>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:wrap-sequence name="source-wrapper" wrapper="source-wrapper"/>
  <p:sink/>
  
  <p:variable name="xsl-base-uri-abspath" select="replace(base-uri(/*), 'file:/+', '/')">
    <p:pipe port="stylesheet" step="xsltmode-as-saxon-command"/>
  </p:variable>
  
  <cx:message>
    <p:with-option name="message" 
      select="concat('Mode: ', ($mode, '#default')[not(. = '')][1], concat('  executable: ''bash ', concat(replace($saxon-call-base-uri, '^file:/+', '/'), '.sh'), ''''))"/>
    <p:input port="source"><p:empty/></p:input>
  </cx:message>
  <p:sink/>
  
  <p:parameters name="consolidate-params">
    <p:input port="parameters">
      <p:pipe port="xslt-params" step="xsltmode-as-saxon-command"/>
    </p:input>
  </p:parameters>
  
  <p:for-each name="source-base-uri-loop">
    <p:iteration-source>
      <p:pipe port="source" step="xsltmode-as-saxon-command"/>
    </p:iteration-source>
    <p:store omit-xml-declaration="false">
      <p:with-option name="method" select="'xml'"/>
      <p:with-option name="indent" select="'false'"/>
      <p:with-option name="href" select="concat($saxon-call-base-uri, '.input', if(p:iteration-position() gt 1) then p:iteration-position() else '')"/>
    </p:store>
    <p:add-attribute attribute-name="href" match="/*">
      <p:input port="source">
        <p:inline>
          <doc/>
        </p:inline>
      </p:input>
      <p:with-option name="attribute-value" select="concat($saxon-call-base-uri, '.input', if(p:iteration-position() gt 1) then p:iteration-position() else '')"/>
    </p:add-attribute>
  </p:for-each>
  
  <p:wrap-sequence name="source-base-uris" wrapper="collection"/>
  
  <p:choose name="write-input-xslt-to-disc-when-received-in-memory">
    <p:when test="not(ends-with($xsl-base-uri-abspath, '.xsl'))">
      <p:store omit-xml-declaration="false">
        <p:input port="source">
          <p:pipe port="stylesheet" step="xsltmode-as-saxon-command"/>
        </p:input>
        <p:with-option name="method" select="'xml'"/>
        <p:with-option name="indent" select="'false'"/>
        <p:with-option name="href" select="concat($saxon-call-base-uri, '.from-memory.xslt')"/>
      </p:store>
      <p:identity>
        <p:input port="source">
          <p:empty/>
        </p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  <p:sink/>
  
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="source-wrapper"/>
    </p:input>
  </p:identity>
  
  <p:choose name="write-saxonconfig-plus-collection">
    <p:when test="count(/*/*) gt 1">
      <p:identity name="saxon-config-start">
        <p:input port="source">
          <p:inline>
            <configuration xmlns="http://saxon.sf.net/ns/configuration">
              <global xmlns="http://saxon.sf.net/ns/configuration"/>
            </configuration>
          </p:inline>
        </p:input>
      </p:identity>
      
      <p:add-attribute name="add-def-coll-attr" match="*:global" attribute-name="defaultCollection">
        <p:with-option name="attribute-value" select="concat($saxon-call-base-uri, '.collection')"/>
      </p:add-attribute>
      
      <p:store omit-xml-declaration="false">
        <p:with-option name="method" select="'xml'"/>
        <p:with-option name="indent" select="'true'"/>
        <p:with-option name="href" select="concat($saxon-call-base-uri, '.config')"/>
      </p:store>
      
      <p:store omit-xml-declaration="false">
        <p:input port="source">
          <p:pipe port="result" step="source-base-uris"/>
        </p:input>
        <p:with-option name="method" select="'xml'"/>
        <p:with-option name="indent" select="'true'"/>
        <p:with-option name="href" select="concat($saxon-call-base-uri, '.collection')"/>
      </p:store>
    </p:when>
    <p:otherwise>
      <p:sink/>
    </p:otherwise>
  </p:choose>
  
  <p:xslt name="saxon-call">
    <p:input port="source">
      <p:pipe port="result" step="consolidate-params"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" exclude-result-prefixes="#all">
          <xsl:param name="mode"/>
          <xsl:param name="saxon-call-base-uri"/>
          <xsl:param name="xsl-base-uri-abspath"/>
          <xsl:param name="source-count"/>
          <xsl:param name="saxon-executable" select="'saxon'"/>
          <xsl:template match="/">
            <xsl:variable name="mode-prefix" 
              select="if(contains($mode, ':')) then substring-before($mode, ':') else ()"/>
            <xsl:variable name="clark-mode-qname" as="node()*">
              <namespace-uri>
                <xsl:choose>
                  <xsl:when test="not(normalize-space($mode-prefix))"/>
                  <xsl:when test="$mode-prefix = 'docx2hub'">{http://transpect.io/docx2hub}</xsl:when>
                  <xsl:when test="$mode-prefix = 's'">{http://purl.oclc.org/dsdl/schematron}</xsl:when>
                  <xsl:when test="$mode-prefix = 'idml2xml'">{http://transpect.io/idml2xml}</xsl:when>
                  <xsl:when test="$mode-prefix = 'docx2hub'">{http://transpect.io/docx2hub}</xsl:when>
                  <xsl:when test="$mode-prefix = 'hub2tei'">{http://transpect.io/hub2tei}</xsl:when>
                  <xsl:when test="$mode-prefix = 'tei2hub'">{http://transpect.io/tei2hub}</xsl:when>
                  <xsl:when test="$mode-prefix = 'html2hub'">{http://transpect.io/html2hub}</xsl:when>
                  <xsl:when test="$mode-prefix = 'xml2tex'">{http://transpect.io/xml2tex}</xsl:when>
                  <xsl:when test="$mode-prefix = 'ttt'">{http://transpect.io/tokenized-to-tree}</xsl:when>
                  <xsl:when test="$mode-prefix = 'hub'">{http://transpect.io/hub}</xsl:when>
                  <xsl:when test="$mode-prefix = 'hub2app'">{http://transpect.io/hub2app}</xsl:when>
                  <xsl:when test="$mode-prefix = 'hub2htm'">{http://transpect.io/hub2htm}</xsl:when>
                  <xsl:when test="$mode-prefix = 'tr3k2html'">{http://www.le-tex.de/namespace/tr3k2html}</xsl:when>
                  <xsl:when test="$mode-prefix = 'tr'">{http://transpect.io}</xsl:when>
                  <xsl:otherwise>
                    <xsl:message select="'&#xa;&#xa;The namespace for your prefix:', $mode-prefix, 'is unknown.&#xa;Your transformation cannot run properly!&#xa;Please add the namspace in', base-uri(), '&#xa;'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </namespace-uri>
              <mode-name>
                <xsl:sequence select="replace($mode, '^[^:]+:(.+)$', '$1')"/>
              </mode-name>
            </xsl:variable>
            <xsl:variable name="xsl-params" 
              select="string-join(for $p in /*:param-set/*:param return concat($p/@name, '=&quot;', $p/@value, '&quot;'), ' ')"/>
            <xsl:variable name="saxon-call-base-abspath" 
              select="replace($saxon-call-base-uri, '^file:/+', '/')"/>
            <xsl:variable name="cmd" as="node()*">
              <processor><xsl:value-of select="$saxon-executable"/></processor>
              <stylesheet>&#x20;-xsl:<file><xsl:value-of select="$xsl-base-uri-abspath"/></file></stylesheet>
              <xsl:if test="not($mode = '') and not($mode = ('#default', '#unnamed'))">
                <initial-mode>&#x20;-im:<xsl:sequence select="$clark-mode-qname"/></initial-mode>
              </xsl:if>
              <source>&#x20;-s:<file><xsl:value-of select="$saxon-call-base-abspath, '.input'" separator=""/></file></source>
              <output>&#x20;-o:<file><xsl:value-of select="$saxon-call-base-abspath, '.output'" separator=""/></file></output>
              <xsl:if test="$source-count ne '1'">
                <saxon-config>&#x20;-config:<file><xsl:value-of select="$saxon-call-base-abspath, '.config'" separator=""/></file></saxon-config>
              </xsl:if>
              <params count="{count(/*:param-set/*:param)}">
                <xsl:for-each select="/*:param-set/*:param">
                  <param>
                    <xsl:text>&#x20;</xsl:text>
                    <name><xsl:value-of select="@name"/></name>
                    <xsl:text>=</xsl:text>
                    <xsl:text>"</xsl:text>
                    <value><xsl:value-of select="@value"/></value>
                    <xsl:text>"</xsl:text>
                  </param>
                </xsl:for-each>
              </params>
            </xsl:variable>
            <c:result>
              <bash-execution>
                <xsl:sequence select="'#!/bin/bash&#xa;cmd=$(cat &lt;&lt;EOF&#xa;', 
                                      string-join($cmd/descendant::text(), ''), 
                                      '&#xa;EOF&#xa;) &amp;&amp; echo $cmd &amp;&amp; eval $cmd'"/>
              </bash-execution>
              <xml text-usable-as-invocation="yes">
                <xsl:sequence select="$cmd"/>
              </xml>
            </c:result>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:with-param name="mode" select="$mode"/>
    <p:with-param name="saxon-call-base-uri" select="$saxon-call-base-uri"/>
    <p:with-param name="xsl-base-uri-abspath" select="if(not(ends-with($xsl-base-uri-abspath, '.xsl'))) 
                                                      then concat($saxon-call-base-uri, '.from-memory.xslt') 
                                                      else $xsl-base-uri-abspath"/>
    <p:with-param name="source-count" select="count(/*/*)">
      <p:pipe port="result" step="source-wrapper"/>
    </p:with-param>
    <p:with-param name="saxon-executable" select="$saxon-executable"/>
  </p:xslt>
  
  <p:delete match="c:result/xml" name="remove-redundant-invocation-call"/>
  
  <p:store name="write-sh" omit-xml-declaration="false">
    <p:with-option name="method" select="'text'"/>
    <p:with-option name="href" select="concat($saxon-call-base-uri, '.sh')"/>
  </p:store>
  
  <p:choose>
    <p:when test="$run-immediately = 'yes'">
      <p:exec name="execute-the-built-saxon-command" cx:depends-on="write-sh" result-is-xml="false">
        <p:input port="source"><p:empty/></p:input>
        <p:with-option name="command" select="'bash'"/>
        <p:with-option name="args" select="concat(replace($saxon-call-base-uri, '^file:/+', '/'), '.sh')"/>
      </p:exec>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source"><p:empty/></p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  <p:sink/>
  
</p:declare-step>