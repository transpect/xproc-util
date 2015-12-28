<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tr="http://transpect.io"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns="http://transpect.io"
  version="1.0"
  name="html-embed-resources"
  type="tr:html-embed-resources">
  
  <p:serialization port="result" method="xhtml" omit-xml-declaration="false"/>
  
  <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
    <h1>tr:html-embed-resources</h1>
    <p>This step tries to embed external resources such as images, 
      CSS and JavaScript via data URI into the HTML document.</p>
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
  
  <p:variable name="top-level-base-uri" select="( /*/@xml:base, base-uri(/*) )[1]"/>
  
  <p:viewport match="*[local-name() = ('img', 'audio', 'video', 'script')][@src]|html:object[@data]|html:link[@rel eq 'stylesheet'][@href]|svg:image[@xlink:href]" name="viewport">
    <p:variable name="local-base-uri" select="(base-uri(.), $top-level-base-uri)[1]"/>
    <p:variable name="href-attribute" select="(*[local-name() = ('img', 'audio', 'video', 'script')]/@src, html:object/@data, html:link/@href, svg:image/@xlink:href)[1]"/>
    <p:variable name="href" 
      select="if(starts-with($href-attribute, 'data:'))  (: leave data URIs as-is :)
              then $href-attribute
              else resolve-uri(if(matches($href-attribute, '^(http[s]?|file)://?')) (: resolve regular URIs :) 
                   then $href-attribute
                   else concat(replace($local-base-uri, '^(.+/).+$', '$1'), $href-attribute),
                   $local-base-uri)"/>
    
    <p:choose>
      <p:when test="not(starts-with($href-attribute, 'data:'))">
        
        <cx:message>
          <p:with-option name="message" select="substring($href-attribute, 1, 20)"/>
        </cx:message>
        
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
              <p:when test="html:img|html:audio|html:video|html:script|html:object|svg:image">
                <p:xpath-context>
                  <p:pipe port="current" step="viewport"/>
                </p:xpath-context>
                <p:variable name="content-type" 
                  select="if(matches(//c:body[1]/@xml:base, '\.svg$', 'i'))
                          then 'image/svg+xml'
                          else replace(//c:body[1]/@content-type, '^(.+/.+);.+$', '$1')"/>
                <p:variable name="encoding" select="//c:body/@encoding"/>
                
                <p:string-replace match="*[local-name() = ('img', 'audio', 'video', 'script')]/@src|html:object/@data|svg:image/@xlink:href|html:video/html:source|html:audio/@src/html:source/@src" cx:depends-on="add-xmlbase">
                  <p:input port="source">
                    <p:pipe port="current" step="viewport"/>
                  </p:input>
                  <p:with-option name="replace" select="concat('''', 'data:', $content-type, ';', $encoding, ',', //c:body, '''')">
                    <p:pipe port="result" step="add-xmlbase"/>
                  </p:with-option>
                </p:string-replace>
                
              </p:when>
              
              <p:otherwise>
                
                <p:insert match="html:style" position="first-child" name="insert-style" cx:depends-on="add-xmlbase">
                  <p:input port="source">
                    <p:inline>
                      <style xmlns="http://www.w3.org/1999/xhtml"></style>
                    </p:inline>
                  </p:input>
                  <p:input port="insertion">
                    <p:pipe port="result" step="add-xmlbase"/>
                  </p:input>
                </p:insert>
                
                <!--  *
                      * process css resources
                      * -->
                
                <cx:message>
                  <p:with-option name="message" select="'extract css references from: ', $href"/>
                </cx:message>
                
                <p:try name="try-extract-references-from-css">
                  <p:group>
                    <p:xslt name="extract-references-from-css">
                      <p:with-param name="base-uri" select="$href"/>
                      <p:input port="stylesheet">
                        <p:document href="../xsl/css-embed-resources.xsl"/>
                      </p:input>
                    </p:xslt>
                    
                    <p:viewport match="tr:data-uri" cx:depends-on="extract-references-from-css" name="viewport-data-uri">
                      <p:variable name="data-uri" select="tr:data-uri/@href"/>
                      <p:variable name="mime-type" select="tr:data-uri/@mime-type"/>
                      
                      <cx:message>
                        <p:with-option name="message" select="'embed: ', $data-uri"></p:with-option>
                      </cx:message>
                      
                      <p:add-attribute attribute-name="href" match="/c:request" name="construct-http-request-css">
                        <p:with-option name="attribute-value" select="$data-uri"/>
                        <p:input port="source">
                          <p:inline>
                            <c:request method="GET" detailed="false"/>
                          </p:inline>
                        </p:input>
                      </p:add-attribute>
                      
                      <p:http-request name="http-request-css-resource" cx:depends-on="construct-http-request-css"/>
                      
                      <p:string-replace match="tr:data-uri/text()">
                        <p:input port="source">
                          <p:pipe port="current" step="viewport-data-uri"/>
                        </p:input>
                        <p:with-option name="replace" select="concat('''', 'data:', $mime-type, ';', c:body/@encoding, ',', replace(c:body, '&#xa;', ''), '''')">
                          <p:pipe port="result" step="http-request-css-resource"/>
                        </p:with-option>
                      </p:string-replace>
                      
                    </p:viewport>
                    
                    <p:unwrap match="html:style//tr:data-uri"/>
                    
                  </p:group>
                  <p:catch>
                    <p:identity>
                      <p:input port="source">
                        <p:pipe port="result" step="insert-style"/>
                      </p:input>
                    </p:identity>
                  </p:catch>
                </p:try>
                
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
        
      </p:when>
      <p:otherwise>
        
        <p:identity>
          <p:input port="source">
            <p:pipe port="current" step="viewport"/>
          </p:input>
        </p:identity>
        
      </p:otherwise>
    </p:choose>
    
  </p:viewport>
  
</p:declare-step>