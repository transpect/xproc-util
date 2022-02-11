<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  version="2.0">
  
  <xsl:param name="file" required="yes"/>
  
  <xsl:template match="/c:result">
    <c:pdf>
      <xsl:attribute name="xml:base" select="$file"/>
      <xsl:attribute name="type" select="'pdfinfo'"/>
      
      <xsl:for-each-group select="c:line" group-starting-with="c:line[matches(., '^[a-z0-9\s]+:\s', 'i')]">
        
        <c:info>
          <xsl:analyze-string select="." regex="^(.+?):">
            <xsl:matching-substring>
              <xsl:attribute name="name" select="normalize-space(regex-group(1))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:attribute name="value" select="normalize-space(replace(., '\p{Cc}', ''))"/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </c:info>
        
      </xsl:for-each-group>
      
    </c:pdf>
  </xsl:template>
  
</xsl:stylesheet>