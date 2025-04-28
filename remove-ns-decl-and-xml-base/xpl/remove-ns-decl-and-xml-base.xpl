<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="remove-ns-decl-and-xml-base" 
  type="tr:remove-ns-decl-and-xml-base">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>The purpose of this identity transformation is to remove all namespace declarations. 
      The step prevents that XProc writes all prefixes declared in the pipeline are written 
      into the output. All namespace declarations are elevated to the root element.</p>
    <p>Furthermore you can use the step to remove all/none or only @xml:base on the root element.</p>
  </p:documentation>
  
  <p:input port="source">
    <p:documentation>Your XML document.</p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation>Your XML document, processed.</p:documentation>
  </p:output>
  
  <p:option name="remove-ns-decl" select="'yes'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Valid values:</p>
      <ul>
        <li>yes: pull all namespace declarations to root-el</li> 
        <li>no: do not change local namespace declarations</li>
      </ul>
    </p:documentation>
  </p:option>
  
  <p:option name="remove-xml-base" select="'yes'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Valid values:</p>
      <ul>
        <li>all, yes (=default, remove all xml:base attributes)</li>
        <li>root (only remove /*/@xml:base);</li>
        <li>none, no (do not remove any @xml:base)</li>
      </ul>
    </p:documentation>
  </p:option>
  
  <p:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:param name="remove-xml-base" select="'all'"/>
          <!-- param remove-ns-decl, valid values:
               - yes: pull all namespace declarations to root-el 
               - no : do not change local namespace declarations -->
          <!-- param remove-xml-base, valid values:
               - all, yes  (default, remove all xml:base attributes)
               - root (only remove /*/@xml:base)
               - none, no (do not remove any @xml:base) -->
          <xsl:param name="remove-ns-decl" select="'yes'"/>
          <xsl:template match="/*" priority="2">
            <xsl:variable name="context" select="."/>
            <xsl:choose>
              <xsl:when test="$remove-ns-decl = 'yes'">
                <xsl:copy copy-namespaces="no">
                  <xsl:for-each select="distinct-values(
                                          ($context//namespace::*/namespace-uri(), 
                                           $context//*[contains(name(), ':')]/namespace-uri())
                                        )">
                    <xsl:variable name="ns" select="."/>
                    <xsl:variable name="el" select="($context//*[namespace-uri()=$ns])[1]"/>
                    <xsl:variable name="name" select="name($el)"/>
                    <xsl:variable name="prefix" select="if(contains($name, ':')) 
                                                        then substring-before($name, ':') 
                                                        else ''"/>
                    <xsl:if test="$prefix ne ''">
                      <xsl:namespace name="{$prefix}" select="$ns"/>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:apply-templates select="@*, node()"/>
                </xsl:copy>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy>
                  <xsl:apply-templates select="@*, node()"/>
                </xsl:copy>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:template>
          <xsl:template match="*[$remove-ns-decl = 'yes'] | @*[$remove-ns-decl = 'yes']" priority="1">
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="* | @*">
            <xsl:copy>
              <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="comment() | processing-instruction()">
            <xsl:copy/>
          </xsl:template>
          <xsl:template match="@xml:base[$remove-xml-base = ('all', 'yes')]" priority="2"/>
          <xsl:template match="@xml:base[$remove-xml-base = 'root' and .. is /*]" priority="2"/>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:with-param name="remove-ns-decl" select="$remove-ns-decl"/>
    <p:with-param name="remove-xml-base" select="$remove-xml-base"/>
  </p:xslt> 
</p:declare-step>
