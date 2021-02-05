<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="params2text"
  type="tr:params2text"
  >
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Converts a &lt;c:param-set&gt; into text (CSV or whitespace separated).</p>
  </p:documentation>
  
  <p:option name="mode" select="'one-line-as-comment'">
    <p:documentation>
      <p>"one-line-as-comment" example output: 
           &lt;!--basename=text.docx debug=yes debug-dir-uri=debug/--&gt;</p>
    </p:documentation>
  </p:option>
  <p:option name="include" select="'*'">
    <p:documentation>by param name, comma separated; '*': include all</p:documentation>
  </p:option>
  <p:option name="exclude" select="'-'">
    <p:documentation>by param name, comma separated; '-': exclude none</p:documentation>
  </p:option>
  <p:option name="separator" select="'&#x20;'"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>

  <p:input port="source" primary="true">
    <p:documentation>Any &lt;c:param-set&gt; element with &lt;c:param&gt; children.</p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>&lt;c:result&gt; with desired content.</p:documentation>
  </p:output>
  <p:serialization port="result" indent="false" omit-xml-declaration="false"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:xslt name="xslt">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:param name="include-params"/>
          <xsl:param name="exclude-params"/>
          <xsl:param name="mode"/>
          <xsl:param name="separator"/>
          <xsl:template match="/*">
            <c:result>
              <xsl:variable name="selected-params" as="element(c:param)*">
                <xsl:sequence 
                  select="c:param[not(@name = tokenize($exclude-params, ','))]
                                 [if($include-params != '*') then @name = tokenize($include-params, ',') else true()]"/>
              </xsl:variable>
              <xsl:variable name="one-liner" as="xs:string?"
                select="string-join(
                          for $i in $selected-params return concat($i/@name, '=', $i/@value),
                          $separator)"/>
              <xsl:choose>
                <xsl:when test="$mode = 'one-line-as-comment'">
                  <xsl:comment><xsl:sequence select="$one-liner"/></xsl:comment>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="$one-liner"/>
                </xsl:otherwise>
              </xsl:choose>
            </c:result>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:with-param name="include-params" select="$include"/>
    <p:with-param name="exclude-params" select="$exclude"/>
    <p:with-param name="mode" select="$mode"/>
    <p:with-param name="separator" select="$separator"/>
  </p:xslt>
  
</p:declare-step>
