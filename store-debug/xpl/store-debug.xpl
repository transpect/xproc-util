<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"    
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io" 
  version="1.0"
  type="tr:store-debug" 
  name="store-debug">
  
  <p:input port="source" sequence="true"/>
  <p:output port="result" sequence="true"/>
  
  <p:option name="active" required="false" select="'no'"/>
  <p:option name="pipeline-step" required="true"/>
  <p:option name="default-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="base-uri" required="false" select="''"/>
  <p:option name="extension" required="false" select="'xml'"/>
  <p:option name="indent" required="false" select="'true'">
    <p:documentation>Indentation may also be set by query string (indent=true|false after a question mark in $default-uri)</p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  
  <p:choose>
    <p:when test="$active = 'yes'">
      <p:xpath-context>
        <p:empty/>
      </p:xpath-context>
      <p:split-sequence initial-only="true" test="position() = 1"/>
      
      <p:group>
        <p:variable name="href0" select="replace($base-uri, '^(.+)\?.*$', '$1')"/>
        <p:variable name="catalog-href" 
                    select="if ($href0 != '') 
                            then concat($href0, '/', $pipeline-step, '.catalog.xml')
                            else concat($default-uri, '/', $pipeline-step, '.catalog.xml')"/>
        <p:for-each name="source-iteration">
          <p:iteration-source>
            <p:pipe port="source" step="store-debug"/>
          </p:iteration-source>
          <p:output port="collection-entries" primary="true"/>
          <p:variable name="href" 
                      select="if ($href0 != '') 
                              then concat($href0, '/', string-join(($pipeline-step, p:iteration-position()[. gt 1], $extension), '.'))
                              else concat($default-uri, '/', string-join(($pipeline-step, p:iteration-position()[. gt 1], $extension), '.'))"/>
          <p:variable name="actual-indent" select="if (matches($base-uri, '^.+\?.*indent=(true|false).*$'))
                                                   then replace($base-uri, '^.+\?.*indent=(true|false).*$', '$1')
                                                   else $indent"/>
          <p:try>
            <!-- try to store to the specified location -->
            <p:group>
              <p:output port="collection-entry" primary="true"/>
              <p:store omit-xml-declaration="false">
                <p:with-option name="indent" select="$actual-indent"/>
                <p:with-option name="href" select="$href"/>
                <p:with-option name="method" select="if (matches($extension, 'html')) then 'xhtml' else 'xml'"/>
              </p:store>
              <p:add-attribute attribute-name="href" match="/*">
                <p:with-option name="attribute-value" select="$href"/>
                <p:input port="source">
                  <p:inline><doc/></p:inline>
                </p:input>
              </p:add-attribute>
            </p:group>
            <!-- print message and catch errors-->
            <p:catch name="catch">
              <p:output port="collection-entry" primary="true"/>
              <cx:message>
                <p:with-option name="message" select="'[WARNING] store-debug failed: Cannot store to the specified location: ', $href"/>
              </cx:message>
              
              <p:add-attribute attribute-name="store-debug-href" match="/c:errors/c:error[1]">
                <p:input port="source">
                  <p:pipe port="error" step="catch"/>
                </p:input>
                <p:with-option name="attribute-value" select="$href"/>
              </p:add-attribute>
              
              <p:store omit-xml-declaration="false">
                <p:with-option name="indent" select="$indent"/>
                <p:with-option name="href" select="if ($href0 != '') 
                  then concat($href0, '/store-debug/store-debug-error.xml')
                  else concat($default-uri, '/store-debug/store-debug-error.xml')" />
              </p:store>
              
              <p:identity>
                <p:input port="source">
                  <p:inline><entry/></p:inline>
                </p:input>
              </p:identity>
            </p:catch>
          </p:try>
            
        </p:for-each>
    
        <p:count name="count-collection-entries"/>

        <p:choose>
          <p:when test=". > 1">
            <p:wrap-sequence wrapper="collection">
              <p:input port="source">
                <p:pipe port="collection-entries" step="source-iteration"/>
              </p:input>
            </p:wrap-sequence>
            <p:store name="store-catalog">
              <p:with-option name="href" select="$catalog-href"/>
            </p:store>
          </p:when>
          <p:otherwise>
            <p:sink name="sink0"/>
          </p:otherwise>
        </p:choose>

        <p:identity>
          <p:input port="source">
            <p:pipe step="store-debug" port="source" />
          </p:input>
        </p:identity>
      </p:group>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>