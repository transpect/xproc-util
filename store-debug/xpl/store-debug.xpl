<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"    
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io" 
  version="3.0"
  type="tr:store-debug" 
  name="store-debug">
  
  <p:input port="source" sequence="true"/>
  <p:output port="result" sequence="true"/>
  
  <p:option name="active" required="false" select="'no'"/>
  <p:option name="pipeline-step" required="true"/>
  <p:option name="default-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="base-uri" required="false" select="''"/>
  <p:option name="extension" required="false" select="''"/>
  <p:option name="indent" required="false" select="'true'">
    <p:documentation>Indentation may also be set by query string (indent=true|false after a question mark in $default-uri).
    The same applies to $active, whether it should write debug files at all. 
    The parameters may be separated by any character, not necessarily '&amp;' or ';'.
    The URI query parameters have precedence over $base-uri and $active, respectively.
    Query parameters may only be 'true' or 'false' while $active may also be 'yes' for historical reasons.
    </p:documentation>
  </p:option>
  
  <p:variable name="actually-active" select="if (matches($base-uri, '^.+\?.*active=(true|false).*$'))
                                             then replace($base-uri, '^.+\?.*active=(true|false).*$', '$1')
                                             else $active">
    <p:empty/>
  </p:variable>  
  <p:choose>
    <p:when test="$actually-active = ('yes', 'true')">
      <p:variable name="actual-indent" select="if (matches($base-uri, '^.+\?.*indent=(true|false).*$'))
                                               then replace($base-uri, '^.+\?.*indent=(true|false).*$', '$1')
                                               else $indent">
        <p:empty/>
      </p:variable>
      <p:xslt name="catalog-and-storage-uris" template-name="main">
        <p:with-option name="parameters"
                   select="
                     map{
                       'storage-base-uri': $base-uri,
                       'default-storage-base-uri': $default-uri,
                       'extension': $extension,
                       'pipeline-step': $pipeline-step
                     }"/>
        <p:with-input port="stylesheet" href="http://transpect.io/xproc-util/store-debug/xsl/store-debug.xsl"/>
      </p:xslt>
      
      <p:sink name="sink0"/>
      
      <p:count>
        <p:with-input port="source">
          <p:pipe port="secondary" step="catalog-and-storage-uris"/>
        </p:with-input>
      </p:count>
      
      <!--<p:message>
        <p:with-option name="select" select="$base-uri"/>
      </p:message>-->
      
      <p:choose>
        <p:when test=". > 1">
          <p:identity>
            <p:with-input port="source">
              <p:pipe port="result" step="catalog-and-storage-uris"/>
            </p:with-input>
          </p:identity>
          <p:store name="store-catalog" serialization="map{'omit-xml-declaration':false(), 'indent':true()}">
            <p:with-option name="href" select="/collection/@xml:base">
              <p:pipe port="result" step="catalog-and-storage-uris"/>
            </p:with-option>
          </p:store>
          <p:sink name="sink1"/>
        </p:when>
        <p:otherwise>
          <p:sink name="sink2"/>
        </p:otherwise>
      </p:choose>
      
      <p:for-each name="store-iteration">
        <p:with-input>
          <p:pipe port="secondary" step="catalog-and-storage-uris"/>
        </p:with-input>
        <p:store serialization="map{'omit-xml-declaration':false(), 'indent': $actual-indent, 'method': if (matches(base-uri(), 'html$')) then 'xhtml' else 'xml'}">
          <p:with-option name="href" select="base-uri()"/>
        </p:store>
      </p:for-each>
      
      <p:identity>
        <p:with-input port="source">
          <p:pipe port="source" step="store-debug"/>
        </p:with-input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>