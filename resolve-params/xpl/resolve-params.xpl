<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="resolve-params"
  type="tr:resolve-params">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>tr:resolve-params</h1>
    <h2>Description</h2>
    <p>This step takes a c:param-set document as input. Parameters which follow the syntax 
      <code><b>${name}</b></code> are resolved with matching parameters from this document. For 
      example the parameter <code>${isbn}</code> will be replaced with the <code>@value</code> 
      of a <code>c:param</code> element which contains a matching <code>@name</code> attribute.</p>
    <p>Given this input document:</p>
    <pre><code>&lt;c:param-set xmlns:c="http://www.w3.org/ns/xproc-step"&gt;
  &lt;param name="isbn" value="(97[89]){1}\d{9}"/&gt;
  &lt;param name="epub-filename" value="<b>{$isbn}</b>\.epub"/&gt;
&lt;/c:param-set&gt;</code></pre>
    <p>This step would resolve the isbn parameter in <code>c:param[@name eq 'epub-filename']</code> 
      and generates this output:</p>
    <pre><code>&lt;c:param-set xmlns:c="http://www.w3.org/ns/xproc-step"&gt;
  &lt;param name="isbn" value="(97[89]){1}\d{9}"/&gt;
  &lt;param name="epub-filename" value="<b>(97[89]){1}\d{9}</b>\.epub"/&gt;
&lt;/c:param-set&gt;</code></pre>
  </p:documentation>
  
  <p:input port="source">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Input port: <code>source</code></h3>
      <p>The source port expects a c:param-set document.</p>
    </p:documentation>
    <p:inline>
      <c:param-set xmlns:c="http://www.w3.org/ns/xproc-step">
        <!--  *
        * books
        * -->
        <c:param name="isbn" value="(97[89]){1}\d{9}(\d|X)"/>
        <c:param name="eisbn-pdf" value="{$isbn}"/>
        <c:param name="eisbn-epub" value="{$isbn}"/>
        <c:param name="isbn-original_epub" value="{$isbn}"/>
        
        <c:param name="chapter-suffix" value="{$isbn}-\w*"/>
        <c:param name="book-delivery-id" value="epub_dgo_{$doi-suffix-book}\.zip"/>
        <c:param name="doi-suffix-book" value="{$eisbn-pdf}"/>
        <c:param name="doi-suffix-book-part" value="{$eisbn-pdf}-{$chapter-suffix}"/>  
        <!--  *
        * journals
        * -->
        <!-- common -->
        <c:param name="journal-code" value="[a-z]+"/>
        <c:param name="journal-code-online" value="[a-z]+"/>
        <c:param name="doi-code" value="[a-z]+"/>
        <c:param name="time-stamp" value="\d{4}(-\d{2}){2}-(-\d{2}){3}"/>
        <!-- article -->
        <c:param name="article-system-creation-date-year" value="\d{4}"/>
        <c:param name="article-counter-id" value="\d{4}"/>
        <c:param name="article-delivery-type" value="(ja|aop)"/>
        <c:param name="article-id" value="{$doi-code}-{$article-system-creation-date-year}-{$article-counter-id}"/>
        <c:param name="article-delivery-id" value="{$journal-code-online}_{$article-id}_{$article-delivery-type}_{$time-stamp}\.zip"/>
        <!-- issue -->
        <c:param name="cover-date-year" value="\d{4}"/>
        <c:param name="volume-number" value="\d+"/>
        <c:param name="issue-number" value="\d+"/>
        <c:param name="issue-id" value="{$journal-code-online}\.{$cover-date-year}\.{$volume-number}\.issue-{$issue-number}"/>
        <c:param name="issue-delivery-id" value="{$journal-code-online}_{$issue-id}_{$time-stamp}\.zip"/>
      </c:param-set>
    </p:inline>
  </p:input>
  
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Output port: <code>result</code></h3>
      <p>The c:param-set document with resolved parameters.</p>
    </p:documentation>
  </p:output>
  
  <!--  *
        * check if input is a valid c:param-set document
        * -->
  <p:validate-with-relax-ng assert-valid="true">
    <p:input port="schema">
      <p:inline>
        <grammar xmlns:c="http://www.w3.org/ns/xproc-step" xmlns="http://relaxng.org/ns/structure/1.0" datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
          <start>
            <element name="c:param-set">
              <oneOrMore>
                <element name="c:param">
                  <interleave>
                    <attribute name="name">
                      <data type="NCName"/>
                    </attribute>
                    <attribute name="value">
                      <data type="anyURI"/>
                    </attribute>
                    <optional>
                      <attribute name="namespace"/>
                    </optional>
                  </interleave>
                </element>
              </oneOrMore>
            </element>
          </start>
        </grammar>
      </p:inline>
    </p:input>
  </p:validate-with-relax-ng>

  <!--  *
        * resolve parameters in c:param-set document
        * -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xsl/resolve-params.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
</p:declare-step>