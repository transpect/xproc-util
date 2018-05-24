<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
  name="mailing"
  type="tr:mailing">
  
  <p:input port="source"><p:empty/></p:input>
  <p:input port="attachments" sequence="true"><p:empty/></p:input>
  <p:output port="result" primary="true" sequence="true"/>
  
  <p:option name="from" required="true"/>
  <p:option name="from-name" select="''"/>
  <p:option name="to" required="true"/>
  <p:option name="content" select="''"/>
  <p:option name="subject" select="'no subject'"/>
  
  <p:xslt name="create-mail" template-name="main">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="source"><p:empty/></p:input>
    <p:with-param name="from" select="$from"/>
    <p:with-param name="from-name" select="$from-name"/>
    <p:with-param name="to" select="$to"/>
    <p:with-param name="content" select="$content"/>
    <p:with-param name="subject" select="$subject"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <xsl:param name="from" as="xs:string" required="yes"/>
          <xsl:param name="from-name" as="xs:string?" required="no"/>
          <xsl:param name="to" as="xs:string+" required="yes"/>
          <xsl:param name="content" as="xs:string" required="yes"/>
          <xsl:param name="subject" as="xs:string" required="yes"/>
          <xsl:template name="main">
            <Message
              xmlns='URN:ietf:params:email-xml:'
              xmlns:rfc822='URN:ietf:params:rfc822:'>
              <rfc822:from>
                <Address>
                  <adrs><xsl:value-of select="$from"/></adrs>
                  <xsl:for-each select="$from-name">
                    <name><xsl:value-of select="."/></name>
                  </xsl:for-each>
                </Address>
              </rfc822:from>
              <rfc822:to>
                <xsl:for-each select="tokenize($to, '\s')[normalize-space()]">
                  <Address>
                    <adrs><xsl:value-of select="."/></adrs>
                    <name></name>
                  </Address>
                </xsl:for-each>
              </rfc822:to>
              <rfc822:subject><xsl:value-of select="$subject"/></rfc822:subject>
              <content type='text/plain'>
                <xsl:value-of select="$content"/>
              </content>
            </Message>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <cx:send-mail>
    <p:input port="source">
      <p:pipe port="result" step="create-mail"/>
      <p:pipe port="attachments" step="mailing"/>
    </p:input>
  </cx:send-mail>
  
</p:declare-step>