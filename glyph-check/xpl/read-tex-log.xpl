<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:tr="http://transpect.io"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  version="1.0">
<!--  <p:input port="source" sequence="false" primary="true"><p:empty/></p:input>-->
  <p:option name="out-prefix" required="false"/>
  
  <p:option name="file" required="true"/>
  <p:option name="report" required="true"/>
  
  <p:option name="debug" required="false" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:output port="errors" >
    <p:pipe port="result" step="generate-errors"/>
  </p:output>
  <p:output port="report" primary="true" >
    <p:pipe port="result" step="patch-report"></p:pipe>
  </p:output>
  
   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl" />
  
  <tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <p:xslt name="generate-errors">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:template match="/*">
            <c:errors>
              <xsl:choose>
                <xsl:when test="unparsed-text-available(@local-href, 'UTF-8')">
                  <xsl:sequence select="tr:parse-textfile(@local-href, 'UTF-8')"/>
                </xsl:when>
                <xsl:when test="unparsed-text-available(@local-href, 'ISO-8859-1')">
                  <xsl:sequence select="tr:parse-textfile(@local-href, 'ISO-8859-1')"/>
                </xsl:when>
                <xsl:otherwise>
                  <c:error name="could-not-load-text-file" value="{@local-href}"/>
                </xsl:otherwise>
              </xsl:choose>
            </c:errors>
          </xsl:template>
          
          <xsl:function name="tr:parse-textfile" as="element(c:error)*">
            <xsl:param name="href" as="xs:string"/>
            <xsl:param name="charset" as="xs:string"/>
            <xsl:variable name="lines" as="xs:string*" 
              select="tokenize(unparsed-text($href, $charset), '(&#xa;&#xa;|&#xd;)')"/>
             <xsl:sequence select="tr:parse-lines($lines)"/>
          </xsl:function>
          
          <xsl:function name="tr:parse-lines" as="element(c:error)*">
            <xsl:param name="lines" as="xs:string*"/>
<!--            <xsl:param name="sep" as="xs:string"/>-->
            <xsl:for-each select="$lines">
              <xsl:analyze-string select="normalize-space(.)" regex="^!.+$">
                <xsl:matching-substring>
                  <c:error code="error" 
                           value="{replace(regex-group(2), '&quot;', '_')}">
                    <xsl:value-of select="."/>
                  </c:error>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:analyze-string select="normalize-space(.)" regex="^LaTeX Warning.+$">
                    <xsl:matching-substring>
                      <c:error code="warning" 
                        value="{replace(regex-group(2), '&quot;', '_')}">
                        <xsl:value-of select="."/>
                      </c:error>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                      <xsl:analyze-string select="normalize-space(.)" regex="Missing character[^\]]+" flags="i">
                        <xsl:matching-substring>
                          <c:error code="error" 
                            value="Missing_Character">
                            <xsl:value-of select="."/>
                          </c:error>
                        </xsl:matching-substring>
                        
                      </xsl:analyze-string>
                    </xsl:non-matching-substring>
                  </xsl:analyze-string>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:for-each>
          </xsl:function>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('texlog/', /*/@lastpath)">
      <p:pipe port="result" step="file-uri"/>
    </p:with-option>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
  <p:sink/>
  
  <tr:file-uri name="report-file-uri">
    <p:with-option name="filename" select="$report"/>
  </tr:file-uri>
  
  <p:load name="load-report">
    <p:with-option name="href" select="/c:result/@local-href"/>
  </p:load>
  
  <p:sink/>
  
   <p:xslt name="patch-report">
     <p:input port="source">
       <p:pipe port="result" step="load-report"/>
       <p:pipe port="result" step="generate-errors"/>
     </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns="http://www.w3.org/1999/xhtml">
          
          <xsl:variable name="errors" select="collection()[/c:errors]/c:errors/*"/>
          
          <xsl:template match="*:div[@class='BC_summary'][not(*:div[normalize-space() =  'TeX Rendering–'])]">
            <xsl:copy>
              <xsl:apply-templates select="@*, node()"/>
              <div class="BC_family-label panel-heading">TeX Rendering<a
                  class="pull-right btn btn-default btn-xs BC_family-label-collapse" role="button"
                  data-toggle="collapse" href="#fam_tex" aria-expanded="false"
                  aria-controls="fam_tex">–</a></div>
              <div class="collapse in" id="fam_tex">
                <ul class="list-group BC_family-summary">
                  <xsl:if test="$errors[@code='error' or @name='could-not-load-text-file']">
                    <li class="list-group-item BC_tooltip error"><div class="checkbox">
                      <label class="checkbox-inline"><input type="checkbox" checked="checked"
                          class="BC_toggle error" id="BC_toggle_found_config__error"
                          name="found_config__error" /></label>
                      <a href="#BC_tex_error" class="BC_link">TeX Rendering Errors<span
                          class="BC_whitespace"> </span><span class="BC_error_count badge">
                        <xsl:value-of select="count($errors[@code='error'])"/>
                          </span></a>
                      <div class="pull-right">
                        <a href="#BC_tex_error" class="BC_link"><span type="button"
                            class="btn btn-default btn-xs error">X<span class="BC_arrow-down"
                              >▾</span></span></a>
                        <span title="Formatierer error tex"
                          class="BC_marker Formatierer error tex"></span>
                      </div>
                    </div></li></xsl:if>
                  <xsl:if test="$errors[@code='warning']">
                    <li class="list-group-item BC_tooltip warning"><div class="checkbox">
                      <label class="checkbox-inline"><input type="checkbox" checked="checked"
                          class="BC_toggle warning" id="BC_toggle_found_config__warning"
                          name="found_config__warning" /></label>
                      <a href="#BC_tex_warning" class="BC_link">TeX Rendering Warnings<span
                          class="BC_whitespace"> </span><span class="BC_warning_count badge">
                        <xsl:value-of select="count($errors[@code='warning'])"/>
                          </span></a>
                      <div class="pull-right">
                        <a href="#BC_tex_warning" class="BC_link"><span type="button"
                            class="btn btn-default btn-xs warning">Y<span class="BC_arrow-down"
                              >▾</span></span></a>
                        <span title="Formatierer warning tex"
                          class="BC_marker Formatierer warning tex"></span>
                      </div>
                    </div></li>
                  </xsl:if>
                </ul>
              </div>
            </xsl:copy>
          </xsl:template>
          
          <xsl:template match="*:p[. is (//*:div[@id='BC_orphans']/*:p)[1]
                                   or
                                   . is (//*:body[not(//*:div[@id='BC_orphans'])]//*:p)[1]
                                  ]">
            <xsl:copy>
              <xsl:apply-templates select="@*, node()"/>
              <span class="BC_tooltip tex-rendering error" style="display:none"><span
                class="btn btn-default btn-xs tex-rendering error" type="button"
                data-toggle="collapse" data-target="#msg_BC_tex_error"
                aria-expanded="false" aria-controls="msg_BC_tex_error">X1</span><span
                  title="tex error tex_error" class="BC_marker tex-rendering error"
                  id="BC_tex_error"></span><div class="collapse" id="msg_tex_error">
                    <div class="well BC_message error">
                      <div class="BC_message-text">TeX errors
                        <xsl:if test="$errors[@name='could-not-load-text-file']">
                          <p>
                            <span class="issue">Could not read tex log file</span>
                            <xsl:value-of select="$errors/@value, 'could not be loaded'"/>
                          </p>
                        </xsl:if>
                        <xsl:for-each select="$errors[@code='error']">
                          <p>
                            <span class="issue"><xsl:value-of select="current()/@value"/></span>
                            <xsl:value-of select="current()/text()"/>
                          </p>
                        </xsl:for-each>
                      </div>
                      <p class="BC_step-name"> Conversion step: TeX Rendering</p>
                    </div>
                  </div></span>
              
              <span class="BC_tooltip tex-rendering warning" style="display:none"><span
                class="btn btn-default btn-xs tex-rendering warning" type="button"
                data-toggle="collapse" data-target="#msg_BC_tex_warning"
                aria-expanded="false" aria-controls="msg_BC_tex_warning">Y1</span><span
                  title="tex warning tex_warning" class="BC_marker tex-rendering warning"
                  id="BC_tex_warning"></span><div class="collapse" id="msg_tex_warning">
                    <div class="well BC_message warning">
                      <div class="BC_message-text">TeX warnings
                        <xsl:for-each select="$errors[@code='warning']">
                          <p>
                            <span class="issue"><xsl:value-of select="current()/@value"/></span>
                            <xsl:value-of select="current()/text()"/>
                          </p>
                        </xsl:for-each>
                      </div>
                      <p class="BC_step-name"> Conversion step: TeX Rendering</p>
                    </div>
                  </div></span>
            </xsl:copy>
          </xsl:template>
          
          <xsl:template match="@* | node()">
            <xsl:copy>
              <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
          </xsl:template>
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <!--<tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('texlog/', /*/@lastpath)">
      <p:pipe port="result" step="file-uri"/>
    </p:with-option>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>-->
  

</p:declare-step>
