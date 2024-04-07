<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:xml2idml="http://transpect.io/xml2idml"
  version="1.0"
  type="tr:prepare-diff"
  name="prepare-diff">
  
  <p:documentation>Removal/normalization of generated IDs and accidental file system URIs
  for generating reference output (and for generating input for diff in order to compare it 
  to the reference output).
  This will work for many debugging outputs of transpect pipelines for different output formats such as
  EPUB, IDML, docx or several XML dialects (JATS/BITS/STS, DocBook/Hub, …).
  You can extend it by making it more configurable and in order to support more output formats, or you
  can just copy it to a9s/common/xpl and modify it according to your project’s needs.</p:documentation>
  
  <p:input port="source" sequence="false" primary="true"><p:empty/></p:input>
  <p:input port="stylesheet">
    <p:document href="../xsl/prepare-diff.xsl"/>
  </p:input>
  
  <p:option name="out-uri-prefix" required="false"/>
  <p:option name="strip-generated" required="false" select="'all'">
    <p:documentation>What to do with Saxon-generated IDs in attributes. Some will be discarded altogether anyway 
      by the stylesheet (for historical reasons – this can be changed), but for others it can be fine-tuned 
      whether to normalize the 'document' part, the 'element' part, 'all', or 'none'.</p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:for-each>
    <p:variable name="out-uri-lastdir" select="tokenize($out-uri-prefix, '/')[last()]"/>
    <p:variable name="input-filename" select="tokenize(base-uri(), '/')[last()]"/>
    <p:variable name="non-redundant-input-filename" 
      select="(substring-after($input-filename, $out-uri-lastdir)[normalize-space()], $input-filename)[1]"/>
    <p:variable name="output-uri" select="concat($out-uri-prefix, '.'[not(starts-with($non-redundant-input-filename, '.'))], $non-redundant-input-filename)"/>
    <p:xslt name="normalize-filerefs">
      <p:with-param name="strip-generated" select="$strip-generated"><p:empty/></p:with-param>
      <p:input port="stylesheet">
        <p:pipe port="stylesheet" step="prepare-diff"/>
      </p:input>
      <p:input port="parameters"><p:empty/></p:input>
    </p:xslt>
    <cx:message>
      <p:with-option name="message" select="'Prepare diff: Store to ', $output-uri"></p:with-option>
    </cx:message>
    <p:store indent="true" omit-xml-declaration="false">
      <p:documentation>Input base URIs for ex.: …/difftest/out-epubtools.xml, …/difftest/out-tei.xml</p:documentation>
      <p:with-option name="href" select="$output-uri"/>
    </p:store>
  </p:for-each>

</p:declare-step>
