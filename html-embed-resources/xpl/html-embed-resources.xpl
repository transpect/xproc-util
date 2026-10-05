<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tr="http://transpect.io"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://transpect.io"
  version="3.1"
  name="html-embed-resources"
  type="tr:html-embed-resources">
  
  <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
    <p>This step tries to embed external resources such as images, 
      CSS and JavaScript as data URI, as XML or as plain text into the HTML document.</p>
    <p>Consider the example below.</p>
    <pre>&lt;html xmlns="http://www.w3.org/1999/xhtml">
  &lt;head>
    &lt;title/>
  &lt;/head>
  &lt;body>
    &lt;div>
      &lt;img alt="a blue square" src="image.png" />
    &lt;/div>
  &lt;/body>
&lt;/html></pre>
    <p>After processing the HTML, the image is embedded as data URI.</p>
    <pre>&lt;html xmlns="http://www.w3.org/1999/xhtml">
  &lt;head>
    &lt;title/>
  &lt;/head>
  &lt;body>
    &lt;div>
      &lt;img alt="a blue square" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAMAAAC6sdbXAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ&#xA;bWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdp&#xA;bj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6&#xA;eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0&#xA;NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJo&#xA;dHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlw&#xA;dGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAv&#xA;IiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RS&#xA;ZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpD&#xA;cmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNl&#xA;SUQ9InhtcC5paWQ6NjExNUU3Q0RFNkQ1MTFFNUE4MThFMjY3QjgwODYwQ0UiIHhtcE1NOkRvY3Vt&#xA;ZW50SUQ9InhtcC5kaWQ6NjExNUU3Q0VFNkQ1MTFFNUE4MThFMjY3QjgwODYwQ0UiPiA8eG1wTU06&#xA;RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo2MTE1RTdDQkU2RDUxMUU1QTgx&#xA;OEUyNjdCODA4NjBDRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo2MTE1RTdDQ0U2RDUxMUU1&#xA;QTgxOEUyNjdCODA4NjBDRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1w&#xA;bWV0YT4gPD94cGFja2V0IGVuZD0iciI/PjJf70IAAAAGUExURQCe4AAAAB0uYYYAAAAOSURBVHja&#xA;YmDABwACDAAAHgABzCCyiwAAAABJRU5ErkJggg==&#xA;" />
    &lt;/div>
  &lt;/body>
&lt;/html></pre> 
  </p:documentation>

  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  
  <p:input port="source" primary="true">
    <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
      <p>expects an XHTML document</p>
    </p:documentation>
    <p:empty/>
  </p:input>
  
  <p:input port="catalog">
    <p:documentation>If it is a <code>&lt;catalog></code> document in the namespace
        <code>urn:oasis:names:tc:entity:xmlns:xml:catalog</code>, it will be used for catalog resolution of URIs that start with
      'http'.</p:documentation>
    <p:inline>
      <nodoc/>
    </p:inline>
  </p:input>
  
  <p:input port="archive-data-uri-map" content-types="application/json">
    <p:documentation>As an extension to its previously established functionality and instead of reading files from disk,
      this step can also read files that are extracted from an archive (and possibly subsequently manipulated by other
      steps). In order to do so, the archive contents and manifest need to be preprocessed by a step like
      <code>tr:archive-data-uri-map</code> that establishes a mapping between what is found in HTML attributes (such as 
      <code>img/@src</code>) and the computed data URIs. 
      Filling CSS <code>url(…)</code> resources using this map is yet unsupported. The map entries, if present for 
      a given HTML attribute value, will have precedence over reading files from disk or via HTTP.</p:documentation>
    <p:inline content-type="application/json" expand-text="false">{}</p:inline>
  </p:input>
  
  <p:output port="result" primary="true"
    serialization="map { 'method': 'xhtml', 'omit-xml-declaration': false() }">
    <p:documentation xmlns:html="http://www.w3.org/1999/xhtml">
      <p>provides the XHTML document with embedded resources</p>
    </p:documentation>
  </p:output>
  
  <p:option name="exclude" select="''">
    <p:documentation>Space-separated list of tokens. Available tokens are: image video script style audio object #all.
    (Question: support font as a category on its own?)</p:documentation>
  </p:option>
  
  <p:option name="include-class-only" select="''">
    <p:documentation>Space-separated list of classnames. When image-tag has such a class, it will be embedded.</p:documentation>
  </p:option>

  <p:option name="exclude-by-fileext" select="''">
    <p:documentation>Space-separated list of file extensions. Files which
    match those extensions are not embedded</p:documentation>
  </p:option>

  <p:option name="max-base64-encoded-size-kb" select="1000">
    <p:documentation>If this limit in KiloByte is exceeded, the resource will not be embedded.</p:documentation>
  </p:option>
  
  <p:option name="unavailable-resource-message" select="'no'">
    <p:documentation>When this option is set to 'yes', a message is inserted for each unavailable resource.</p:documentation>
  </p:option>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="fail-on-error" select="'true'"/>
  
  <p:declare-step version="3.1"
    name="tr-get-data-uri" 
    type="tr:get-data-uri">
    
    <p:documentation>
      This step performs a simple p:http-request and 
      checks whether the result exceeds the limit
      of the base64 encoded size. If this check fails,
      the original fileref markup is reproduced.
    </p:documentation>
    
    <p:input port="fileref" primary="false">
      <p:documentation>
        Markup of the file reference. Will be replicated if 
        base64 encoded size of the file reference exceeds limit.
      </p:documentation>
    </p:input>
    <p:input port="file-uri" primary="false">
      <p:documentation>
        The result of tr:file-uri for the URI that should be embedded
      </p:documentation>
    </p:input>
    
    <p:output port="result"/>
    
    <p:option name="href" required="true">
      <p:documentation>The (resolved) URI to fetch</p:documentation>
    </p:option>
    <p:option name="force-octet-stream" select="'no'">
      <p:documentation>Fetch as application/octet-stream so that the body is
        guaranteed to be base64 encoded</p:documentation>
    </p:option>
    <p:option name="max-base64-encoded-size-kb" select="'1000'"/>
    
    <p:choose name="fetch">
      <p:with-input><p:empty/></p:with-input>
      <p:when test="starts-with($href, 'http')">
        <p:http-request name="http-fetch" method="get" href="{$href}">
          <p:with-input port="source"><p:empty/></p:with-input>
        </p:http-request>
      </p:when>
      <p:when test="$force-octet-stream eq 'yes'">
        <p:load name="load-octet" href="{$href}" content-type="application/octet-stream"/>
        <!-- p:xslt accepts XML documents only (binary documents must not reach its
             source port, err:XD0038); cast the binary document to a c:data document -->
        <p:cast-content-type name="octet-to-cdata" content-type="application/xml"/>
      </p:when>
      <p:otherwise>
        <!-- Local file: XML documents pass through, binary documents become c:data.
             Text documents cannot be cast to XML (the processor would try to parse
             the text as markup, err:XD0049) — read them as plain text instead. -->
        <p:try>
          <p:group>
            <p:load name="load-file" href="{$href}"/>
            <p:cast-content-type name="file-to-cdata" content-type="application/xml"/>
          </p:group>
          <p:catch name="catch-text-cast">
            <p:xslt name="load-file-as-text" template-name="main">
              <p:with-input port="source">
                <p:inline>
                  <dummy/>
                </p:inline>
              </p:with-input>
              <p:with-input port="stylesheet">
                <p:inline expand-text="false">
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
                    <xsl:param name="href" as="xs:string"/>
                    <xsl:template name="main">
                      <c:body content-type="application/xml">
                        <xsl:value-of select="unparsed-text($href)"/>
                      </c:body>
                    </xsl:template>
                  </xsl:stylesheet>
                </p:inline>
              </p:with-input>
              <p:with-option name="parameters" select="map { 'href': $href }"/>
            </p:xslt>
          </p:catch>
        </p:try>
      </p:otherwise>
    </p:choose>

    <p:xslt name="normalize-body">
      <p:with-input port="stylesheet">
        <p:inline expand-text="false">
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
            <xsl:template match="/">
              <xsl:choose>
                <xsl:when test="c:data">
                  <c:body content-type="{c:data/@content-type}" encoding="base64">
                    <xsl:value-of select="c:data"/>
                  </c:body>
                </xsl:when>
                <xsl:when test="c:body">
                  <!-- already normalized (text fallback path) -->
                  <xsl:sequence select="."/>
                </xsl:when>
                <xsl:otherwise>
                  <c:body content-type="application/xml">
                    <xsl:sequence select="node()"/>
                  </c:body>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:with-input>
    </p:xslt>
    
    <p:choose name="test-for-max-file-size">
      <p:with-input pipe="@normalize-body"/>
      <p:when test="xs:float(string-length(//c:body[1]) * 4 div 3 div 1000) &gt; xs:float($max-base64-encoded-size-kb)">

      <p:variable name="base64-str-size" select="string-length(//c:body[1]) * 4 div 3 div 1000"/>
        <p:variable name="href" select="/*/@local-href" pipe="file-uri@tr-get-data-uri"/>
        
        <p:message>
          <p:with-option name="select" select="'[WARNING] File not embedded. Base64 encoded string size (',
            round-half-to-even($base64-str-size, 2) , 
            'kB) exceeds limit of ', $max-base64-encoded-size-kb, ' kB: ', $href"/>
        </p:message>
        
        <p:sink/>
        
        <p:identity>
          <p:with-input port="source" pipe="fileref@tr-get-data-uri"/>
        </p:identity>
        
      </p:when>
      <p:otherwise>
        
        <p:identity/>
        
      </p:otherwise>
    </p:choose>
    
  </p:declare-step>

  <p:group name="main">
  
  <p:variable name="top-level-base-uri" select="( /*/@xml:base, base-uri(/*) )[1]"/>
  
  <p:variable name="suppress-video" select="tokenize($exclude, '\s+')[. = ('#all', 'video')]"/>
  <p:variable name="suppress-audio" select="tokenize($exclude, '\s+')[. = ('#all', 'audio')]"/>
  <p:variable name="suppress-image" select="tokenize($exclude, '\s+')[. = ('#all', 'image')]" />
  <p:variable name="suppress-script" select="tokenize($exclude, '\s+')[. = ('#all', 'script')]"/>
  <p:variable name="suppress-style" select="tokenize($exclude, '\s+')[. = ('#all', 'style')]"/>
  <p:variable name="suppress-object" select="tokenize($exclude, '\s+')[. = ('#all', 'object')]"/>
  
  <p:variable name="archive-data-uri-map" as="map(*)" select="." pipe="archive-data-uri-map@html-embed-resources"/>
  
  <p:viewport match="*[local-name() = ('img', 'audio', 'video', 'script')][@src]
                     |html:object[@data]
                     |html:link[@rel eq 'stylesheet'][@href]
                     |svg:image[@xlink:href]" 
              name="viewport">
    
    <p:variable name="local-base-uri" select="(base-uri(.)[normalize-space()], $top-level-base-uri)[1]"/>
    <p:variable name="href-attribute" select="replace(
                                                      (*[local-name() = ('img', 'audio', 'video', 'script')]/@src, 
                                                       html:object/@data, 
                                                       html:link/@href, 
                                                       svg:image/@xlink:href)[1],
                                                       '\\', '/')"/>
    <p:variable name="href-attribute-normalized" 
                select="replace(replace(replace($href-attribute, '\[', '%5B'), '\]', '%5D'), '\s', '%20')"/>
    <p:variable name="href" 
      select="if(starts-with($href-attribute, 'data:'))  (: leave data URIs as-is :)
              then $href-attribute-normalized
              else if(map:contains($archive-data-uri-map, $href-attribute-normalized))
                   then map:get($archive-data-uri-map, $href-attribute-normalized)
                   else resolve-uri(if(matches($href-attribute-normalized, '^(http[s]?|file)://?')) (: resolve regular URIs :) 
                                    then $href-attribute-normalized
                                    else concat(replace($local-base-uri, '^(.+/).+$', '$1'), $href-attribute-normalized),
                                    $local-base-uri)"/>
    <p:variable name="fileext" select="lower-case(replace($href, '^.+\.([a-z0-9]+)?$', '$1', 'i'))"/>
    <p:variable name="class-attribute" select="*/@class"/>
    <p:variable name="matches-classes" select="if (not($include-class-only) or (($class-attribute) and matches($class-attribute,string-join(tokenize($include-class-only,'\s'),'|')))) then 'true' else ''"/>
    <p:choose>
      <p:when test="exists(
                        /*[local-name() = ('img'[$suppress-image],
                                           'audio'[$suppress-audio], 
                                           'video'[$suppress-video], 
                                           'script'[$suppress-script])][@src]
                      | /html:object[@data][$suppress-object]
                      | /html:link[@rel eq 'stylesheet'][@href][$suppress-style]
                      | /svg:image[@xlink:href][$suppress-image]
                    ) 
                    or 
                    $fileext = tokenize(lower-case($exclude-by-fileext), '\s')">
        <p:documentation>Suppress embedding for elements meeting these conditions. Unfortunately, the conditions could not
        be specified in the p:viewport match attribute because options and variables seem to be inaccessible there.</p:documentation>
        <p:identity/>
      </p:when>
      
      <p:when test="$matches-classes and (normalize-space($href-attribute) and not(starts-with($href, 'data:')))">
        <p:try>
          <p:group>
            <p:choose>
              <p:when test="$debug eq 'yes'">
                <p:message>
                  <p:with-option name="select" select="'embed: ', $href"/>
                </p:message>
              </p:when>
              <p:otherwise>
                <p:identity/>
              </p:otherwise>
            </p:choose>
            
            <!-- * 
                 * resolve URIs with tr:file-uri, construct and perform http-request
                 * -->
            
            <tr:file-uri fetch-http="true" name="file-uri">
              <p:with-option name="filename" select="$href"/>
              <p:with-input port="catalog">
                <p:pipe port="catalog" step="html-embed-resources"/>
              </p:with-input>
              <p:with-input port="resolver">
                <p:document href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
              </p:with-input>
            </tr:file-uri>
            
            <p:sink/>
            
            <tr:get-data-uri name="http-request">
              <p:with-input port="fileref">
                  <p:pipe port="current" step="viewport"/>
              </p:with-input>
                <p:with-input port="file-uri">
                  <p:pipe port="result" step="file-uri"/>
                </p:with-input>
              <p:with-option name="href" select="/c:result/@local-href">
                <p:pipe port="result" step="file-uri"/>
              </p:with-option>
              <p:with-option name="max-base64-encoded-size-kb" select="$max-base64-encoded-size-kb"/>
            </tr:get-data-uri>
            
            <p:add-attribute attribute-name="xml:base" name="add-xmlbase" match="//c:body">
              <p:with-option name="attribute-value" select="$href"/>
            </p:add-attribute>
            
            <!-- * 
                 * include the base64 string as data-URI or as text node
                 * -->
            
            <p:choose>
                <p:with-input pipe="current@viewport"/>
              <p:when test="/html:img|html:audio|html:video|html:script|html:object|svg:image|html:picture">
                <p:variable name="content-type" 
                  select="if(matches(//c:body[1]/@xml:base, '\.svg$', 'i'))
                          then 'image/svg+xml'
                            else replace(//c:body[1]/@content-type, '^(.+/.+);.+$', '$1')"
                    pipe="result@add-xmlbase"/>
                  <p:variable name="encoding" select="//c:body/@encoding" pipe="result@add-xmlbase"/>
                
                <p:string-replace match="*[local-name() = ('img', 'audio', 'video', 'script')]/@src
                                         |html:object/@data
                                         |svg:image/@xlink:href
                                         |html:video/html:source/@src
                                         |html:audio/@src
                                         |html:picture/html:source/@srcset">
                  <p:with-input port="source">
                    <p:pipe port="current" step="viewport"/>
                  </p:with-input>
                  <p:with-option name="replace" select="concat('''', 'data:', $content-type, ';', $encoding, ',', //c:body, '''')">
                    <p:pipe port="result" step="add-xmlbase"/>
                  </p:with-option>
                </p:string-replace>
                
              </p:when>
              
              <p:otherwise>
                
                <p:insert match="html:style" position="first-child" name="insert-style">
                  <p:with-input port="source">
                    <p:inline>
                      <style xmlns="http://www.w3.org/1999/xhtml"></style>
                    </p:inline>
                  </p:with-input>
                  <p:with-input port="insertion">
                    <p:pipe port="result" step="add-xmlbase"/>
                  </p:with-input>
                </p:insert>
                
                <!--  *
                      * process css resources
                      * -->
                
                <p:try name="try-extract-references-from-css">
                  <p:group>
                    <p:xslt name="extract-references-from-css">
                      <p:with-input port="stylesheet">
                        <p:document href="../xsl/css-embed-resources.xsl"/>
                      </p:with-input>
                        <p:with-option name="parameters"
                          select="map { 'base-uri': $href,
                                        'suppress-image': $suppress-image }"/>
                    </p:xslt>
                    
                    <p:viewport match="tr:data-uri" name="viewport-data-uri">
                      <p:variable name="data-uri" select="tr:data-uri/@href"/>
                      <p:variable name="mime-type" select="tr:data-uri/@mime-type"/>
                      
                      <tr:file-uri fetch-http="true" name="css-file-uri">
                        <p:with-option name="filename" select="$data-uri"/>
                        <p:with-input port="catalog">
                          <p:pipe port="catalog" step="html-embed-resources"/>
                        </p:with-input>
                        <p:with-input port="resolver">
                          <p:document href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
                        </p:with-input>
                      </tr:file-uri>
                      
                      <p:choose name="foo">
                        <p:when test="true()(:$debug eq 'yes':)">
                          <p:message>
                            <p:with-option name="select" select="'CSS embed: ', $data-uri,
                              if (not($data-uri = /*/@local-href)) 
                              then (', resolved as ', /*/@local-href)
                              else ()"/>
                          </p:message>
                        </p:when>
                        <p:otherwise>
                          <p:identity/>
                        </p:otherwise>
                      </p:choose>

                      <tr:get-data-uri name="http-request-css-resource">
                        <p:with-input port="fileref">
                          <p:pipe port="current" step="viewport-data-uri"/>
                        </p:with-input>
                        <p:with-input port="file-uri">
                          <p:pipe port="result" step="css-file-uri"/>
                        </p:with-input>
                          <p:with-option name="href" select="/*/@local-href">
                            <p:pipe port="result" step="css-file-uri"/>
                          </p:with-option>
                          <p:with-option name="force-octet-stream" select="'yes'"/>
                        <p:with-option name="max-base64-encoded-size-kb" select="$max-base64-encoded-size-kb"/>
                      </tr:get-data-uri>
                      
                      <p:choose name="conditionally-replace-css-uri">
                        <p:when test="name(/*) = 'c:body'">
                          <p:string-replace match="tr:data-uri/text()">
                            <p:with-input port="source">
                              <p:pipe port="current" step="viewport-data-uri"/>
                            </p:with-input>
                            <p:with-option name="replace" select="concat('''', 'data:', $mime-type, ';', c:body/@encoding, ',', replace(c:body, '&#xa;', ''), '''')">
                              <p:pipe port="result" step="http-request-css-resource"/>
                            </p:with-option>
                          </p:string-replace>    
                        </p:when>
                        <p:otherwise>
                          <p:string-replace match="tr:data-uri/text()">
                            <p:with-input port="source">
                              <p:pipe port="current" step="viewport-data-uri"/>
                            </p:with-input>
                            <p:with-option name="replace" select="concat('''', /*/@local-href, '''')">
                              <p:pipe port="result" step="css-file-uri"/>
                            </p:with-option>
                          </p:string-replace>
                        </p:otherwise>
                      </p:choose>
                      
                    </p:viewport>
                    
                    <p:unwrap match="html:style//tr:data-uri"/>
                    
                  </p:group>
                  <p:catch>
                    <p:identity>
                      <p:with-input port="source">
                        <p:pipe port="result" step="insert-style"/>
                      </p:with-input>
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
          
          <p:catch name="catch-embed">
            
            <p:choose>
              <p:when test="$fail-on-error eq 'true'">
                
                <p:error code="html-resource-embed-failed">
                  <p:with-input port="source">
                      <p:pipe port="error" step="catch-embed"/>
                  </p:with-input>
                </p:error>
                
              </p:when>
              <p:otherwise>
                
                <p:identity>
                  <p:with-input port="source">
                    <p:pipe port="current" step="viewport"/>
                  </p:with-input>
                </p:identity>
                
                <p:choose>
                  <p:when test="$unavailable-resource-message eq 'yes'">
                    
                    <p:xslt name="insert-unavailable-resource-message">
                      <p:with-input port="stylesheet">
                        <p:document href="../xsl/unavailable-resource-message.xsl"/>
                      </p:with-input>
                    </p:xslt>
                    
                  </p:when>
                  <p:otherwise>
                    
                    <p:identity/>
                    
                  </p:otherwise>
                </p:choose>
                
                <p:message>
                  <p:with-option name="select" select="'[WARNING] failed to embed file: ', $href"/>
                </p:message>
                
              </p:otherwise>
            </p:choose>
            
          </p:catch>
        </p:try>
        
      </p:when>
      <p:otherwise>
        
        <p:identity>
          <p:with-input port="source">
            <p:pipe port="current" step="viewport"/>
          </p:with-input>
        </p:identity>
        
      </p:otherwise>
    </p:choose>
    
  </p:viewport>
  
  </p:group>

</p:declare-step>
