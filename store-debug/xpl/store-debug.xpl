<p:library 
  xmlns:p="http://www.w3.org/ns/xproc"    
  xmlns:tr="http://transpect.io" 
  version="1.0">

  <p:declare-step type="tr:store-debug" name="store-debug">
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true"/>
    <p:option name="active" required="false" select="'no'"/>
    <p:option name="pipeline-step" required="true"/>
    <p:option name="default-uri" required="false" select="resolve-uri('debug')"/>
    <p:option name="base-uri" required="false" select="''"/>
    <p:option name="extension" required="false" select="'xml'"/>
    <p:option name="indent" required="false" select="'true'"/>
    
    <p:choose>
      <p:when test="$active = 'yes'">
        <p:for-each name="source-iteration">
          <p:store omit-xml-declaration="false">
            <p:with-option name="indent" select="$indent"/>
            <p:with-option name="href" select="if ($base-uri != '') 
                                               then concat($base-uri, '/', $pipeline-step, '.', $extension)
                                               else concat($default-uri, '/', $pipeline-step, '.', $extension)" />
            <p:with-option name="method" select="if (matches($extension, 'html')) then 'xhtml' else 'xml'"/>
          </p:store>
        </p:for-each>
        <p:identity>
          <p:input port="source">
            <p:pipe step="store-debug" port="source" />
          </p:input>
        </p:identity>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>
  </p:declare-step>


</p:library>