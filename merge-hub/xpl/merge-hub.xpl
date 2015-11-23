<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:tr="http://transpect.io"
	xmlns:merge-hub="http://transpect.io/xproc-util/merge-hub"
	version="1.0"
	name="merge-hub"
	type="tr:merge-hub">
	
	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<h1>tr:merge-hub</h1>
		<p>This step expects a sequence of Hub files and merges them to one single file.</p>
	  <h2>Dependencies</h2>
	  <ul>
	    <li>
	      <p><b>functx path-to-node-with-pos</b></p>
	      <p>https://subversion.le-tex.de/common/functx/XML_Elements_and_Attributes/XML_Document_Structure/path-to-node-with-pos.xsl</p>
	    </li>
	    <li>
	      <p><b>store-debug</b></p>
	      <p>https://subversion.le-tex.de/common/xproc-util/store-debug/store-debug.xpl</p>
	    </li>
	  </ul>
	</p:documentation>
  	
	<p:input port="source" sequence="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2>Input <i>source</i></h2>
			<p>The input port expects a sequence of Hub documents.</p>
		</p:documentation>
	</p:input>
	
	<p:output port="result" sequence="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2>Output <i>result</i></h2>
			<p>The result port provides a single Hub document.</p>
		</p:documentation>
	  <p:pipe port="result" step="merge"/>
	</p:output>
  
  <p:output port="report">
    <p:documentation xmlns="htttp://www.w3.org/1999/xhtml">
      <h2>Output <i>result</i></h2>
      <p>The report port provides a Schematron SVRL document.</p>
    </p:documentation>
    <p:pipe port="result" step="generate-report"/>
  </p:output>
  
  <p:option name="debug" select="'yes'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Option: <code>debug</code></h3>
      <p>Used to switch debug mode on or off. Pass 'yes' to enable debug mode.</p>
    </p:documentation>
  </p:option> 
  
  <p:option name="debug-dir-uri" select="'debug'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Option: <code>debug-dir-uri</code></h3>
      <p>Expects a file URI of the directory that should be used to store debug information.</p> 
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  
  <p:wrap-sequence wrapper="document" wrapper-namespace="http://xmlcalabash.com/ns/extensions" wrapper-prefix="cx"/>
	
  <tr:store-debug pipeline-step="merge-hub/pre-merge">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
	
  <p:xslt initial-mode="merge-hub:merge" name="merge">
	  <p:input port="parameters">
	    <p:empty/>
	  </p:input>
	  <p:input port="stylesheet">
	    <p:document href="../xsl/merge-hub.xsl"/>
	  </p:input>
	</p:xslt>
  
  <p:delete match="*[@csstmp:*]"/>
  
  <tr:store-debug pipeline-step="merge-hub/post-merge">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:xslt initial-mode="generate-report" name="generate-report">
    <p:input port="source">
      <p:pipe port="result" step="merge"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/merge-hub.xsl"/>
    </p:input>
  </p:xslt>
	
</p:declare-step>
