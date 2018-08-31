# unwrap-mml
Library to convert simple MathML equations to XML/plaintext

## Description

Besides LaTeX, MathML is in most cases the preferred format for the markup
of math equations. However, simple equations and formula symbols do not
necessarily need to be presented as MathML. In certain scenarios, it's more
convenient to render the equations as plain text, for example to accelerate the
rendering of the document, to decrease file size or to bypass lacking MathML
support in some reading systems (poor you!).

## How it works

Common math styles (bold, italic, bold-italic) and superscripts and subscripts are
tagged with the appriopriate elements of the document XML schema. Letters in other
styles (e.g. double-struck, fraktur, script) are mapped to their Unicode equivalent.

```xml
<math xmlns="http://www.w3.org/1998/Math/MathML">
  <msup>
    <mi>x</mi>
    <mn>2</mn>
  </msup>
</math>
```

The expression above converted to XHTML:


```xml
<i>x</i><sup>2</sup>
```

You can find the full examples [here](https://github.com/transpect/unwrap-mml/blob/master/example).

## Configuration

Create an XSLT stylesheet and import `xsl/unwrap-mml.xsl`.

```xml
<xsl:import href="unwrap-mml.xsl"/>
```

Override the following parameters (XSD type: _element()_) to create appropriate
wrapper elements for your target XML grammar:

* wrapper (wrapper for the entire equation)
* superscript
* subscript
* bold
* italic
* bold-italic

Here is an example on how to configure that MathML superscripts are replaced
with DocBook superscripts:

```xml
<xsl:param name="superscript" as="element()">
  <superscript xmlns="http://docbook.org/ns/docbook"/>
</xsl:param>
```

Note: If you want to convert MathML to pure plaintext, just declare all parameters as empty.

Use the function _tr:unwrap-mml-boolean()_ as condition in your template
to determine whether the MathML can be unwrapped or not. Apply subsequent
templates in the XSLT mode `unwrap-mml`.

```xml
<xsl:template match="*:inlineequation[mml:math[tr:unwrap-mml-boolean(.)]]">
  <xsl:apply-templates mode="unwrap-mml"/>
</xsl:template>
```

You can configure at which size an equation won't be unwrapped. Therefore, you
can set a limit for the maximum numbers of operators. If an equation has more
operators than the operator limit, it won't be unwrapped. Please note that the
operator limit represents `<mo>`s except those which contain parentheses or
just whitespace.

```xml
<xsl:param name="operator-limit" select="1" as="xs:integer"/>
```

Note: unwrap-mml requires that MathML comes with the namespace URI
`http://www.w3.org/1998/Math/MathML`. If this is not the case, you must attach
the namespace first and then invoke unwrap-mml. You can find an example
in `xsl/unwrap-mml-aplusplus.xsl`

