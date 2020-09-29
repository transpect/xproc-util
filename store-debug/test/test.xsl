<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0" exclude-result-prefixes="#all">
  
  <xsl:param name="collection-uri" as="xs:string?" select="()"/>
   
  <xsl:template name="main">
    <result count="{count(collection($collection-uri))}"
      uris="{for $d in collection($collection-uri) return base-uri($d)}"/>
  </xsl:template>

</xsl:stylesheet>
