<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0"
  name="html-embed-resources"
  type="tr:html-embed-resources">
  
  <p:serialization port="result" method="xhtml" omit-xml-declaration="false"/>
  
  <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
    <h1>tr:html-embed-resources</h1>
    <p>Collect all resources of an XHTML document and make them inline available</p>
  </p:documentation>
  
  <p:input port="source">
    <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
      <p>expects an XHTML document</p>
    </p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
      <p>provides the XHTML document with embedded resources</p>
    </p:documentation>
  </p:output>
  
  <p:option name="fail-on-error" select="'true'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:variable name="base-uri" select="/*/@xml:base"/>
  
  <p:viewport match="*[local-name() = ('img', 'audio', 'video', 'script')][@src]|html:object[@data]|html:link[@rel eq 'stylesheet'][@href]" name="viewport">
    <p:variable name="href-attribute" select="(*[local-name() = ('img', 'audio', 'video', 'script')]/@src, html:object/@data, html:link/@href)[1]"/>
    <p:variable name="href" 
      select="resolve-uri(if(matches($href-attribute, '^(http[s]?|file)://?')) 
                          then $href-attribute
                          else concat(replace($base-uri, '^(.+/).+$', '$1'), $href-attribute),
                          $base-uri)
                          "/>
    
    <p:try>
      <p:group>
        
        <cx:message>
          <p:with-option name="message" select="'embed: ', $href"/>
        </cx:message>
        
        <!-- * 
             * construct and perform http-request
             * -->
        
        <p:add-attribute attribute-name="href" match="/c:request" name="construct-http-request">
          <p:with-option name="attribute-value" select="$href"/>
          <p:input port="source">
            <p:inline>
              <c:request method="GET" detailed="false"/>
            </p:inline>
          </p:input>
        </p:add-attribute>
        
        <p:http-request name="http-request"/>
        
        <p:add-attribute attribute-name="xml:base" name="add-xmlbase" match="//c:body" cx:depends-on="http-request">
          <p:with-option name="attribute-value" select="$href"/>
        </p:add-attribute>
        
        <!-- * 
             * include the base64 string as data-URI or as text node
             * -->
        
        <p:choose>
          <p:when test="html:img|html:audio|html:video|html:script|html:object">
            <p:xpath-context>
              <p:pipe port="current" step="viewport"/>
            </p:xpath-context>
            <p:variable name="content-type" select="if(matches(//c:body[1]/@xml:base, '\.svg$', 'i'))
              then 'image/svg+xml'
              else replace(//c:body[1]/@content-type, '^(.+/.+);.+$', '$1')"/>
            <p:variable name="encoding" select="//c:body/@encoding"/>
            
            <p:string-replace match="*[local-name() = ('img', 'audio', 'video', 'script')]/@src|html:object/@data" cx:depends-on="add-xmlbase">
              <p:input port="source">
                <p:pipe port="current" step="viewport"/>
              </p:input>
              <p:with-option name="replace" 
                select="concat('''', 
                               'data:', 
                               $content-type, 
                               ';',
                               $encoding,
                               ',',
                               //c:body,
                '''')">
                <p:pipe port="result" step="add-xmlbase"/>
              </p:with-option>
            </p:string-replace>
            
          </p:when>
          
          <p:otherwise>
            
            <p:insert match="html:style" position="first-child" cx:depends-on="add-xmlbase">
              <p:input port="source">
                <p:inline>
                  <style xmlns="http://www.w3.org/1999/xhtml"></style>
                </p:inline>
              </p:input>
              <p:input port="insertion">
                <p:pipe port="result" step="add-xmlbase"/>
              </p:input>
            </p:insert>
            
            <p:unwrap match="html:style//c:body"/>
            
          </p:otherwise>
          
        </p:choose>
        
      </p:group>
      
      <!--  *
            * the try branch failed for any™ reason. Leave the reference as is
            * -->
      
      <p:catch>
        
        <p:choose>
          <p:when test="$fail-on-error eq 'true'">
            
            <p:error code="html-resource-embed-failed">
              <p:input port="source">
                <p:inline>
                  <c:error>Failed to embed HTML resource.</c:error>
                </p:inline>
              </p:input>
            </p:error>
            
          </p:when>
          <p:otherwise>
            
            <p:identity>
              <p:input port="source">
                <p:pipe port="current" step="viewport"/>
              </p:input>
            </p:identity>
            
            <cx:message>
              <p:with-option name="message" select="'[WARNING] failed to embed file: ', $href"/>
            </cx:message>
            
          </p:otherwise>
        </p:choose>
        
      </p:catch>
    </p:try>
    
  </p:viewport>
  
</p:declare-step>