<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  type="tr:copy-files" name="copy-files">

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>Hub XML document</p:documentation>
  </p:input>
  <p:output port="result" primary="true" sequence="true">
    <p:documentation>The input, optionally with changed paths</p:documentation>
  </p:output>
  
  <p:option name="retain-subpaths" required="false" select="'false'">
    <p:documentation>Remove subpaths for every fileref attribute. 
      false: files will be copied to $target-dir-uri directly.</p:documentation>
  </p:option>
  
  <p:option name="target-dir-uri" required="true">
    <p:documentation>Copy files into this directory</p:documentation>
  </p:option>
  
  <p:option name="change-uri" required="false" select="'yes'" >
    <p:documentation>Modify the fileref attribute of the hub input?</p:documentation>
  </p:option>
  
  <p:option name="change-uri-new-subpath" required="false" select="'media'" >
    <p:documentation>Prefix this string to all filerefs?</p:documentation>
  </p:option>
  
  <p:option name="fileref-attribute-name-regex" required="false" select="'^fileref$'" >
    <p:documentation>attribute name of the file reference containing attribute</p:documentation>
  </p:option>

  <p:option name="fileref-hosting-element-name-regex" required="false" 
    select="'^(audiodata|imagedata|textdata|videodata)$'">
    <p:documentation>element name hosting the fileref attribute. default: see Hub/Docbook</p:documentation>
  </p:option>

  <p:option name="fileref-attribute-value-regex" required="false" select="'^.+$'">
    <p:documentation>Default: Match any URI. You can limit it to absolute file URIs by supplying '^file:/'.</p:documentation>
  </p:option>

  <p:option name="fail-on-error" required="false" select="'false'">
    <p:documentation>Default value for basic steps pxf:mkdir and pxf:copy is true. Here it is false.
    This will also be passed to the XSLT. If different source files will be copied to a single target,
    the XSLT will terminate if $fail-on-error is true.</p:documentation>
  </p:option>

  <p:documentation>The behavior can be partly overridden by using @hub:target-fileref attributes on the same element
  as the @fileref (or whatever $fileref-attribute-name-regex matches) attribute. If @hub:target-fileref is a relative
  URI, it will be resolved wrt $target-dir-uri. If it is an absolute URI, it will have precedence over $target-dir-uri.
  If @hub:target-fileref is present, the original @fileref attribute will not be changed. 
  Libraries such as hub2docx should prefer @hub:target-fileref in order to determine the location. 
  </p:documentation>

  <!-- debugging options -->
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" required="false" select="'debug/status?enabled=false'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>

  <p:load name="load-stylesheet" 
          href="http://transpect.io/xproc-util/copy-files/xsl/copy-files.xsl"/>

  <p:xslt name="generate-copy-instructions" template-name="create-entries-from-hub">
    <p:with-param name="retain-subpaths" select="$retain-subpaths"/>
    <p:with-param name="target-dir-uri" select="$target-dir-uri"/>
    <p:with-param name="fail-on-error" select="$fail-on-error"/>
    <p:with-param name="fileref-attribute-name-regex" select="$fileref-attribute-name-regex"/>
    <p:with-param name="fileref-attribute-value-regex" select="$fileref-attribute-value-regex"/>
    <p:with-param name="fileref-hosting-element-name-regex" select="$fileref-hosting-element-name-regex"/>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-stylesheet"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="copy-files"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <tr:store-debug name="debug-copy-entries">
    <p:with-option name="pipeline-step" 
      select="concat('copy-files','/01.copy-instructions')"/><!--/', tokenize(base-uri(/*), '/')[last()], '-->
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:for-each name="copy-each-file-to-new-location">
    <p:iteration-source select="/c:copy-files/c:entry"/>

    <pxf:mkdir name="create-target-dir">
      <p:with-option name="href" select="string-join(tokenize(/*/@target, '/')[position() != last()], '/')"/>
      <p:with-option name="fail-on-error" select="$fail-on-error"/>
    </pxf:mkdir>

    <p:try>
      <p:group>
        <!--<p:output port="report" primary="false" sequence="true">
          <p:pipe port="result" step="success"/>
        </p:output>-->
        <pxf:copy name="just-copy">
          <p:with-option name="href" select="/*/@href">
            <p:pipe port="current" step="copy-each-file-to-new-location"/>
          </p:with-option>
          <p:with-option name="target" select="/*/@target">
            <p:pipe port="current" step="copy-each-file-to-new-location"/>
          </p:with-option>
          <p:with-option name="fail-on-error" select="'false'"/>
        </pxf:copy>
        <!--<p:add-attribute attribute-name="href" match="/*">
          <p:with-option name="attribute-value" select="/*/@href">
            <p:pipe port="current" step="copy-each-file-to-new-location"/>
          </p:with-option>
          <p:input port="source">
            <p:inline><c:success/></p:inline>
          </p:input>
        </p:add-attribute>-->
      </p:group>
      <p:catch name="catch">
        <!--<p:output port="report" primary="false" sequence="true">
          <p:pipe port="result" step="forward-error"/>
        </p:output>-->
        <tr:propagate-caught-error name="forward-error" rule-family="Internal" severity="error" code="TRCPF01"
          step-type="tr:copy-files">
          <p:input port="source">
            <p:pipe port="error" step="catch"/>
          </p:input>
          <p:with-option name="fail-on-error" select="$fail-on-error">
            <p:empty/>
          </p:with-option>
          <p:with-option name="msg-file" select="concat($debug-dir-uri, 'copy-files/', /*/@href, '.error.txt')">
            <p:pipe port="current" step="copy-each-file-to-new-location"/>
          </p:with-option>
          <p:with-option name="status-dir-uri" select="$status-dir-uri">
            <p:empty/>
          </p:with-option>
        </tr:propagate-caught-error>
        <p:sink/>
      </p:catch>
    </p:try>
  </p:for-each>

  <p:choose name="modify-hub-source">
    <p:when test="$change-uri eq 'yes'">
      <p:xslt name="change-uri-in-hub" initial-mode="change-uri">
        <p:with-param name="retain-subpaths" select="$retain-subpaths"/>
        <p:with-param name="change-uri-new-subpath" select="$change-uri-new-subpath"/>
        <p:with-param name="fileref-attribute-name-regex" select="$fileref-attribute-name-regex"/>
        <p:with-param name="fileref-hosting-element-name-regex" select="$fileref-hosting-element-name-regex"/>
        <p:input port="source">
          <p:pipe port="source" step="copy-files"/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="result" step="load-stylesheet"/>
        </p:input>
      </p:xslt>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="copy-files"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

</p:declare-step>
