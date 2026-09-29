<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://transpect.io" 
  xmlns:pos="http://exproc.org/proposed/steps/os"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  version="3.1" 
  name="file-uri" 
  type="tr:file-uri">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>This step accepts either a file system path or a URL in its 'filename' option. It will normalize them so that both a file
      system path and a file: URL are available. If filename starts with http: or https:, the file will be retrieved and stored
      locally. Please note that this retrieval will not work for remote directories.</p>
    <p>Its primary uses are</p>
    <ul>
      <li>giving users the liberty to either specify a URL or an OS-specific path for input file parameters;</li>
      <li>making XML catalog resolution available to any URI, not just when accessing resources through catalog-enabled methods
        such as <code>doc()</code>;</li>
      <li>if, after optional catalog resolution, the 'filename' URI is still http:/https:, <code>p:http-request</code> will be
        used to store the file locally.</li>
    </ul>
    <h5>Examples for 'filename' values</h5>
    <ul>
      <li><code>C:/temp/file.docx</code>,</li>
      <li><code>c:\temp\file.docx</code>,</li>
      <li><code>file:/C:/temp/file.docx</code>,</li>
      <li><code>file:///C:/temp/file.docx</code>,</li>
      <li><code>/tmp/file.docx</code>,</li>
      <li><code>subdir/file.docx</code>,</li>
      <li><code>https://github.com/me/myrepo/blob/master/file.docx?raw=true</code></li>
    </ul>
    <h5>Relative Paths</h5>
    <p>Relative paths will be resolved against the current working directory, which is better than the static base uri most of the
      time but which might not always be what the user wants. It is a good idea to absolutize paths, as in 
      <code>$(readlink -f subdir/file.docx)</code> or <code>$(cygpath -ma subdir/file.docx)</code>.</p>
    <h5>XML Catalogs</h5>
    <p>If a catalog is provided on the catalog port and an <a
      href="https://github.com/transpect/xslt-util/blob/master/xslt-based-catalog-resolver/">XSLT stylesheet for catalog resolution</a> is supplied on the 
      resolver port, http:/https: URIs will be catalog-resolved first, see below.</p>
    <h5>Storage Location for HTTP Downloads</h5>
    <p>It is possible to specify a temporary directory in the 'tmpdir' option. By default, it will be the subdir 'tmp' of the
      user’s home directory. The 'tmpdir' option accepts both a file: URL and an OS path, thanks to this normalization step.</p>
    <p>Please note that temporary files will not be deleted by this step.</p>
    <h5>Unique File Names for HTTP Downloads</h5>
    <p>If the option 'make-unique' is true (which it is by default), the files that are fetched by <code>p:http-request</code>
      will get a random string like <code>_0fa8d348</code> appended to their base name.</p>
    <h5>Output format</h5>
    <p>The output is a <code>c:result</code> element with the following attributes:</p>
    <dl>
      <dt><code>os-path</code></dt>
      <dd>OS-specific path. This is always present except when there is <code>error-status</code></dd>
      <dt><code>local-href</code></dt>
      <dd>file: URI. This is always present except when there is <code>error-status</code></dd>
      <dt><code>error-status</code></dt>
      <dd>This may only happen if the 'filename' was an HTTP URI and if there was an error retrieving the resource</dd>
      <dt><code>href</code></dt>
      <dd>The post catalog-resolution URI of the resource (if it is an HTTP URI)</dd>
      <dt><code>orig-href</code></dt>
      <dd>The pre catalog-resolution URI of the resource (if different from post catalog)</dd>
      <dt><code>lastpath</code></dt>
      <dd>For ordinary files, the non-directory part including suffix. For directories, the last path component without trailing slash.
      lastpath is URL-escaped, that is, it is taken from local-href.</dd>
      <dt><code>lastpath-os</code></dt>
      <dd>The same as <code>lastpath</code>, but without URL escaping.</dd>
    </dl>
  </p:documentation>
  
<!--  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>-->
  <p:import href="unescape-for-os-path.xpl"/>

  <p:pipeinfo>
    <depends-on xmlns="http://transpect.io">
      <module href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/" min-version="r1688"/>
    	<module href="http://transpect.io/xslt-util/resolve-uri/" min-version="r3504"/>
    </depends-on>
  </p:pipeinfo>

  <p:option name="filename" required="true" as="xs:string">
    <!-- xs:string (as the effective XProc 1 type) so that an accidentally
         empty sequence is rejected at binding time; an empty $filename used
         to fall through the relative-path branch and re-invoke tr:file-uri
         with resolve-uri(()) until the stack overflowed. -->
    <p:documentation>A URI or an OS-specific identifier. Relative paths will be resolved against the static-base-uri(). A future
      improvement might use the XSLT-based catalog resolver in order to detect whether a given http: URL will actually resolve
      to a local file.</p:documentation>
  </p:option>
  <p:option name="make-unique" required="false" select="'true'">
    <p:documentation>Whether to store files retrieved over HTTP with a unique random name in the temp dir.</p:documentation>
  </p:option>
  <p:option name="fetch-http" required="false" select="'true'">
    <p:documentation>Whether to fetch files referenced by URIs matching '^https?:'.</p:documentation>
  </p:option>
  <p:option name="check-http" required="false" select="'true'">
    <p:documentation>Whether to check that the HTTP status of '^https?:' URIs matches '[23]\d\d'.
    check-http and fetch-http should be made mutually exclusive. For the time being, if both are
    given, fetch-http has precedence. With the given default values, this means that you need to specify
    both check-http=true and fetch-http=false if you only want to check.</p:documentation>
  </p:option>
  <p:option name="tmpdir" required="false" select="''">
    <p:documentation>URI or OS name of a directory for storing files retrieved via HTTP.</p:documentation>
  </p:option>
  <p:option name="use-filename-from-http-response" required="false" select="'no'">
    <p:documentation>Use filename that is passed on from http request response instead of 
    possible filename read from URL (for example when using Gdocs URLs:
    https://docs.google.com/document/d/1Z5eYyjLoRhB24HYZ-d-wQKAFD3QDWZUsQH4cKHs2eiM/export?format=docx)</p:documentation>
  </p:option>

  <!--<p:input port="source" primary="true">
    <p:documentation>Just to prevent that the default readable port will be connected to the catalog or resolver
      ports.</p:documentation>
    <p:empty/>
  </p:input>-->

  <p:input port="catalog">
    <p:documentation>If it is a <code>&lt;catalog></code> document in the namespace
        <code>urn:oasis:names:tc:entity:xmlns:xml:catalog</code>, it will be used for catalog resolution of URIs that start with
      'http'.</p:documentation>
    <p:inline>
      <nodoc/>
    </p:inline>
  </p:input>

  <p:input port="resolver">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>An XSLT stylesheet that provides the named template <code>resolve</code>. This template takes a parameter
          <code>$uri</code> and produces a document <code>&lt;result unresolved="{$uri}"/></code>. If the URI could be resolved
        to another URI, the result will take the form <code>&lt;result unresolved="{$uri}"
        resolved="{$resolved-uri}"/></code>.</p>
      <p>By default, this step only provides trivial (i.e., identity plus URL escaping) catalog resolution.</p>
      <p>You have to supply an XSLT-based catalog resolver on the resolver port in order to use catalog resolution. That is
        because native catalog resolution is not available for p:http-request or by XPath function. This means that you can’t
        programmatically decide whether to retrieve a file via <span class="step">p:http-request</span> or use the local file.</p>
      <p>You may use the <a
        href="https://github.com/transpect/xslt-util/blob/master/xslt-based-catalog-resolver/"
          >repository version</a> of the XSLT-based resolver. However, in order to avoid network traffic, you should consider
        using a local copy. In order to avoid importing it via its absolute or relative file system path, you should use the
        transpect appoach of importing the resolver’s XML catalog via <code>&lt;nextCatalog</code> from your project catalog.
        Then you can import the XSLT-based resolver by its <a
          href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl">canonical
        URI</a>.</p>
    </p:documentation>
    <p:document href="../xsl/without-resolver.xsl"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>A c:result document with a local-href and an os-path attribute.</p:documentation>
  </p:output>

  <!-- p:os-info is not available in MorganaXProc-IIIse. The fallback provides an equivalent
       c:os-info document: cwd is derived from the PWD environment variable when it looks
       like an absolute POSIX path, otherwise from this library’s base URI. Caveat: some
       processors do not expose the real environment PWD (MorganaXProc reports a value
       based on the pipeline location), so relative filenames may resolve differently than
       with p:os-info — prefer absolute or catalog-resolved filenames on such processors.
       user-home is derived from USERPROFILE or HOME and may be empty. -->
  <p:variable name="os-cwd" select="
    if (matches(environment-variable('PWD'), '^/[a-zA-Z]/'))
    then translate(concat(upper-case(substring(environment-variable('PWD'), 2, 1)), ':/',
                         substring(environment-variable('PWD'), 4)), '/', '\')
    else translate(replace(static-base-uri(), '^file:/+([a-zA-Z]:.*)/[^/]+$', '$1'), '/', '\')">
    <p:empty/>
  </p:variable>
  <p:variable name="os-user-home"
    select="translate((environment-variable('USERPROFILE'), environment-variable('HOME'), '')[1], '/', '\')">
    <p:empty/>
  </p:variable>
  <p:identity name="info" use-when="not(p:step-available('p:os-info'))">
    <p:with-input port="source">
      <p:inline expand-text="true">
        <c:os-info cwd="{$os-cwd}"
                   user-home="{$os-user-home}"
                   file-separator="{if (matches(static-base-uri(), '^file:/+[a-zA-Z]:')) then '\' else '/'}"/>
      </p:inline>
    </p:with-input>
  </p:identity>
  <p:os-info name="info" use-when="p:step-available('p:os-info')"/>

  <p:xslt name="catalog-resolve" template-name="resolve">
    <p:with-input port="stylesheet">
      <p:pipe port="resolver" step="file-uri"/>
    </p:with-input>
    <p:with-input port="source">
      <p:pipe port="catalog" step="file-uri"/>
    </p:with-input>
    <p:with-option name="parameters" select="map {'uri': if (/*/@file-separator = '\') then replace($filename, '\\', '/') else $filename,
                                          'cat:missing-next-catalogs-warning': 'no' }"/>
  </p:xslt>
  
  <!--<cx:message>
    <p:with-option name="message" select="'cr ', for $a in /*/@* return concat(name($a), '=', $a, ' ')"></p:with-option>
  </cx:message>-->
  <p:sink/>

  <p:add-attribute name="empty-result" attribute-name="cwd" match="/*">
    <p:with-input port="source">
      <p:inline>
        <c:result/>
      </p:inline>
    </p:with-input>
    <p:with-option name="attribute-value" 
      select="replace(
                if (/*/@file-separator = '\') 
                then replace(/*/@cwd, '\\', '/') 
                else /*/@cwd,
                '([^/])$',
                '$1/'
              )">
      <p:pipe port="result" step="info"/>
    </p:with-option>
  </p:add-attribute>
  
  <p:choose name="cwd-uri">
    <p:when test="$filename = /c:result/@cwd">
      <p:output port="result" primary="true"/>
      <p:identity/>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <tr:file-uri>
        <p:with-option name="filename" select="/c:result/@cwd"/>
      </tr:file-uri>
    </p:otherwise>
  </p:choose>
  
  
  <!--<tr:file-uri name="cwd-uri">
    <p:with-option name="filename" select="/c:result/@cwd"/>
  </tr:file-uri>-->
  
  <p:sink name="sink1"/>

  <p:set-attributes name="add-orig-href" match="/c:result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>If the URL has been catalog-resolved, the original URL will be copied here from the preceding XSLT step, in an
        orig-href attribute. Apart from that, the XSLT step has to prodce an href attribute.</p>
      <p>Please note that despite its name, the @href attribute doesn’t necessarily contain a URI. If $filename is an OS path,
        @href will contain this path.</p>
    </p:documentation>
    <p:with-input port="source">
      <p:pipe port="result" step="empty-result"/>
    </p:with-input>
    <p:with-option name="attributes" select="map:merge((for $a in (//*/@*)[1]
                                                         return map { $a/local-name() : $a/string() }))">
      <p:pipe port="result" step="catalog-resolve"/>
    </p:with-option>
  </p:set-attributes>
  
  <p:group>
    <p:variable name="catalog-resolved-uri" select="/c:result/@href"/>

    <p:choose name="analyze-filename">
      <p:when test="matches($catalog-resolved-uri, '^jar:')">
        <p:documentation>We should analyze what comes next. Currently we just assume that a file: URI will follow.
        What should be the content of @os-path? We skip @os-path altogether for the time being.</p:documentation>
        <p:add-attribute attribute-name="local-href" match="/*">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
          <p:with-input port="source">
            <p:inline>
              <c:result/>
            </p:inline>
          </p:with-input>
        </p:add-attribute>
        <p:add-attribute attribute-name="href" match="/*">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^file://[^/]')">
        <p:documentation>Windows UNC path URI.</p:documentation>
        <p:add-attribute attribute-name="local-href" match="/*">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
          <p:with-input port="source">
            <p:inline>
              <c:result/>
            </p:inline>
          </p:with-input>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="os-path">
          <p:with-option name="attribute-value" select="replace($catalog-resolved-uri, '^file://', '\\')"/>
        </p:add-attribute>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^file:/')">
        <p:documentation>Unix file URI or Windows file: URI containing a drive letter.</p:documentation>
        <p:add-attribute match="/*" attribute-name="local-href" name="local-href">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="os-path">
          <p:with-option name="attribute-value" 
            select="replace(replace($catalog-resolved-uri, '^file:/+([a-z]:/)', '$1', 'i'), '^file:/+', '/')"/>
          <!-- Under strange conditions the following more compact replacement would not evaluate 
            correctly with Calabash 1.1.5 and Saxon 9.6.0.7 or 9.6.0.9
            Input: file:///C:/cygwin/home/gerrit/Dev/epubtools-xproc/
            Output (incorrect): /cygwin/home/gerrit/Dev/epubtools-xproc/
            Standalone invocation of file-uri was ok, but the step output-file-name in epub-convert.xpl yielded 
            the wrong output.
          <p:with-option name="attribute-value" select="replace($catalog-resolved-uri, '^file:/+(([a-z]:)/)?', '$2/', 'i')"/>
          -->
        </p:add-attribute>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:when>

      <p:when test="matches($catalog-resolved-uri, '^/')">
        <p:documentation>Unix Filename</p:documentation>
        <p:add-attribute match="/*" attribute-name="local-href">
          <p:with-option name="attribute-value" select="concat('file://', $catalog-resolved-uri)"/>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="os-path">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^xmldb:', 'i')">
        <p:documentation>eXist db resource path</p:documentation>
        <p:add-attribute match="/*" attribute-name="local-href">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="os-path">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:when>

      <p:when test="matches($catalog-resolved-uri, '^[a-z]:', 'i')">
        <p:documentation>Windows path, either with forward or backward slashes.</p:documentation>
        <p:add-attribute match="/*" attribute-name="local-href">
          <p:with-option name="attribute-value" select="concat('file:///', replace($catalog-resolved-uri, '\\', '/'))"/>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="os-path">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:when>

      <p:when test="matches($catalog-resolved-uri, '^https?:') and $fetch-http = 'true'">
        <p:documentation>HTTP URL. Since there is no system property for a temp dir, store it in the subdir tmp of the user’s
          home dir. Optionally generate a random name.</p:documentation>

        <p:uuid match="/*/@uuid" name="uuid">
          <p:with-input port="source">
            <p:inline>
              <doc uuid=""/>
            </p:inline>
          </p:with-input>
        </p:uuid>

        <p:sink/>
        
        <tr:file-uri name="tmp-dir">
          <p:with-option name="filename" select="($tmpdir[normalize-space()], concat(/c:result/@user-home, '/tmp/'))[1]">
            <p:pipe port="result" step="info"/>
          </p:with-option>
        </tr:file-uri>
        
        <p:identity>
            <p:with-input port="source">
              <p:inline>
                <c:request method="GET" detailed="true"/>
              </p:inline>
            </p:with-input>
          </p:identity>

        <p:add-attribute match="/c:request" attribute-name="href">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
<!--      following lines throw " Alternative subpipelines must have the same primary output port"    -->
        <!--<p:try name="http-request">
          <p:group>
            <p:output port="result" primary="true"/>
            <p:output port="result" primary="true" pipe="result@http-request-intern"/>
            <p:http-request name="http-request-intern">
              <p:with-option name="href" select="/c:request/@href"/>
            </p:http-request>
            <p:sink/>
            <p:variable name="status" as="xs:string" select="xs:string(.?status-code)" pipe="report@http-request-intern"/>
            <p:identity>
              <p:with-input port="source">
                <p:inline expand-text="true">
                  <c:response name="status" value="{$status}"/>
                </p:inline>
              </p:with-input>
            </p:identity>
          </p:group>
          <p:catch>
            <p:output port="result" primary="true"/>
            <p:output port="result" primary="true" pipe="result@catch-res1"/>
            <p:identity name="catch-res1">
              <p:with-input port="source">
                <p:inline>
                  <c:response status="999"/>
                </p:inline>
              </p:with-input>
            </p:identity>
          </p:catch>
        </p:try>-->
        
    <!--<p:identity name="http-request">
              <p:with-input port="source">
                <p:inline>
                  <c:response status="999"/>
                </p:inline>
              </p:with-input>
            </p:identity>-->
        
        <p:http-request name="http-request">
          <p:with-option name="href" select="/c:request/@href"/>
        </p:http-request>
        <p:sink/>
        <p:variable name="status" as="xs:string" select="xs:string(.?status-code)" pipe="report@http-request"/>
        <p:identity name="http-request-result">
          <p:with-input port="source">
            <p:inline expand-text="true">
              <c:response status="{$status}"/>
            </p:inline>
          </p:with-input>
        </p:identity>
        
        <p:group>
          <p:variable name="tmp-dir-href" select="/c:result/@local-href">
            <p:pipe port="result" step="tmp-dir"/>
          </p:variable>

           <p:variable name="filename" select="replace(map:get(.?headers, 'Content-Disposition'),
                                             '^.*filename=&#34;(.*)&#34;;.*$',
                                             '$1')" as="item()" pipe="report@http-request"/>
          <p:add-attribute attribute-name="local-href" match="/*" name="local-href">
            <p:with-input port="source">
              <p:pipe port="result" step="uuid"/>
            </p:with-input>
            <p:with-option name="attribute-value"
              select="concat(
                            $tmp-dir-href, 
                             if ($use-filename-from-http-response = 'yes') 
                            then $filename
                            else
                            concat(replace(
                              replace($catalog-resolved-uri, '^.+/', ''),
                              '(.+?)([.?#].+)?', 
                              '$1'
                            ),
                            if ($make-unique = 'true') then concat('_', substring(/*/@uuid, 1, 8)) else '',
                            replace(replace(replace($catalog-resolved-uri, '^.+/', ''), '^[^?#.]+', ''), '[?#].*$', ''))
                          )">
              <p:pipe port="result" step="uuid"/>
            </p:with-option>
          </p:add-attribute>

          <p:sink/>
          
          <p:identity>
            <p:with-input port="source">
              <p:pipe port="result" step="http-request"/>
            </p:with-input>
          </p:identity>
          
          <p:choose name="store-http-resource">
            <p:when test="not(starts-with($status, '2'))">
              <p:message>
                <p:with-option name="select"
                  select="concat('Cannot retrieve ', $catalog-resolved-uri, '. Status: ', $status)"/>
              </p:message>
              <p:sink/>
              <p:add-attribute attribute-name="error-status" match="/c:result">
                <p:with-option name="attribute-value" select="$status">
                  <p:pipe port="result" step="http-request"/>
                </p:with-option>
                <p:with-input port="source">
                  <p:inline>
                    <c:result/>
                  </p:inline>
                </p:with-input>
              </p:add-attribute>
            </p:when>
            <p:when test="/c:response/c:body/(.[normalize-space(.)] | c:data)">
                
              <p:add-attribute  match="/doc" attribute-name="filename" name="filename">
                <p:with-option name="attribute-value" 
                  select="$filename"/>
                <p:with-input port="source">
                  <p:pipe port="result" step="local-href"/>
                </p:with-input>
              </p:add-attribute>
              
             <!--<p:store cx:decode="true">
                <p:input port="source" select="/c:response">
                  <p:pipe port="result" step="http-request"/>
                </p:input>
                <p:with-option name="href" select="'response.txt'">
                  <p:pipe port="result" step="local-href"/>
                </p:with-option>
              </p:store>-->

                <p:store cx:decode="true">
                <p:with-input port="source" select="/c:response/c:body">
                  <p:pipe port="result" step="http-request"/>
                </p:with-input>
                <p:with-option name="href" select="/doc/@local-href">
                     <p:pipe port="result" step="filename"/>
                </p:with-option>
              </p:store>
              <tr:file-uri name="http-to-local-result_binary">
                <p:with-option name="filename" select="/doc/@local-href">
                    <p:pipe port="result" step="filename"/>
                </p:with-option>
              </tr:file-uri>
            </p:when>
            <p:otherwise>
              <p:store serialization="map{'omit-xml-declaration':false()}">
                <p:with-input port="source" select="/c:response/c:body/*">
                  <p:pipe port="result" step="http-request"/>
                </p:with-input>
                <p:with-option name="href" select="/doc/@local-href">
                  <p:pipe port="result" step="local-href"/>
                </p:with-option>
              </p:store>
              <tr:file-uri name="http-to-local-result_xml">
                <p:with-option name="filename" select="/doc/@local-href">
                  <p:pipe port="result" step="local-href"/>
                </p:with-option>
              </tr:file-uri>
            </p:otherwise>
          </p:choose>
          <p:add-attribute match="/c:result" attribute-name="href">
            <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
          </p:add-attribute>
        </p:group>
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^https?:') and $check-http = 'true'">
        <p:documentation>HTTP URL, check only return status Ok.</p:documentation>

        <p:identity>
          <p:with-input port="source">
            <p:inline>
              <c:request method="HEAD" detailed="true" status-only="true"/>
            </p:inline>
          </p:with-input>
        </p:identity>

        <p:try name="http-request-check">
          <p:group>
            <p:add-attribute match="/c:request" attribute-name="href">
              <p:with-option name="attribute-value" select="escape-html-uri($catalog-resolved-uri)"/>
            </p:add-attribute>
            <p:http-request name="http-request-check-intern">
              <p:with-option name="href" select="/c:request/@href"/>
            </p:http-request>
            <p:variable name="status" as="xs:string" select="xs:string(.?status-code)" pipe="report@http-request-check-intern"/>
            <p:identity name="response">
              <p:with-input port="source">
                <p:inline expand-text="true">
                  <c:response status="{$status}"/>
                </p:inline>
              </p:with-input>
            </p:identity>
          </p:group>
          <p:catch name="catch-http-request-check">
            <p:insert name="insert" match="/*" position="first-child">
              <p:with-input port="source">
                <p:inline>
                  <c:response status="999"/>
                </p:inline>
              </p:with-input>
              <p:with-input port="insertion">
                <p:pipe port="error" step="catch-http-request-check"/>
              </p:with-input>
            </p:insert>
          </p:catch>
        </p:try>
        
        <p:identity name="result-http-request-check"/>

        <p:sink/>
        <p:variable name="http-request-check-status" select="/c:response/@status">
            <p:pipe port="result" step="result-http-request-check"/>
        </p:variable>
<!--        formerly named <choose name="attach-error-status"> -->
        <p:choose>
          <p:when test="not(starts-with($http-request-check-status, '2'))">
            <p:add-attribute attribute-name="error-status" match="/c:result">
              <p:with-input port="source">
                <p:inline>
                  <c:result/>
                </p:inline>
              </p:with-input>
              <p:with-option name="attribute-value" select="/c:response/@status">
                <p:pipe port="result" step="result-http-request-check"/>
              </p:with-option>
            </p:add-attribute>
          </p:when>
          <p:otherwise>
            <p:identity>
              <p:with-input port="source">
                <p:inline>
                  <c:result/>
                </p:inline>
              </p:with-input>
            </p:identity>
          </p:otherwise>
        </p:choose>

        <p:add-attribute match="/c:result" attribute-name="href">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>
        <!--<cx:message>
                <p:with-option name="message"
                  select="'GGGGGGGGGGGG ', string-join(for $n in /* return (name($n), for $a in $n/@* return concat(name($a), '=', $a)), ' ')"
                />
              </cx:message>-->
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^https?:')">
        <p:documentation>HTTP URL, do not fetch content or check availability.</p:documentation>
        <p:identity/>
      </p:when>
      
      <p:when test="matches($catalog-resolved-uri, '^\\\\[^\\]')">
        <p:documentation>Windows UNC path. \\ → file:///// .</p:documentation>
        <p:add-attribute attribute-name="os-path" match="/*">
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
          <p:with-input port="source">
            <p:inline>
              <c:result/>
            </p:inline>
          </p:with-input>
        </p:add-attribute>
        <p:add-attribute match="/*" attribute-name="local-href">
          <p:with-option name="attribute-value" select="concat('file:///', replace($catalog-resolved-uri, '\\', '/'))"/>
        </p:add-attribute>
      </p:when>

      <p:when test="matches($catalog-resolved-uri, '^(#|mailto:|ftp:)')">
        <p:add-attribute attribute-name="href" match="/*">
          <p:with-input port="source">
            <p:inline>
              <c:result local-href="" os-path=""/> 
            </p:inline>
          </p:with-input>
          <p:with-option name="attribute-value" select="$catalog-resolved-uri"/>
        </p:add-attribute>        
      </p:when>

      <p:otherwise>
        <p:documentation>Other protocol or relative filename. We don’t support other protocols/notations, so we assume it to be
          a relative path.</p:documentation>
        <tr:file-uri name="resolved-uri">
          <p:with-option name="filename" select="resolve-uri($catalog-resolved-uri, /c:result/@local-href)">
            <p:pipe port="result" step="cwd-uri"/>
          </p:with-option>
        </tr:file-uri>
        <tr:unescape-uri attribute-names="os-path"/>
      </p:otherwise>
    </p:choose>
  </p:group>

  <p:add-attribute name="lastpath" attribute-name="lastpath" match="/*">
    <p:with-option name="attribute-value" select="replace(/*/@local-href, '^.+/([^/]*)/*$', '$1')"/>
  </p:add-attribute>
  
  <p:add-attribute name="lastpath-os" attribute-name="lastpath-os" match="/*">
    <p:with-option name="attribute-value" select="replace(/*/@os-path, '^.*/([^/]*)/*$', '$1')"/>
  </p:add-attribute>

  <p:xslt name="add-rel-path">
    <p:with-input port="stylesheet">
      <p:document href="../xsl/attach-relative-path.xsl"/>
    </p:with-input>
    <p:with-option name="parameters" select="map {'cwd-uri': /c:result/@local-href}">
      <p:pipe port="result" step="cwd-uri"/>
    </p:with-option>
  </p:xslt>

</p:declare-step>
