<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:tr="http://transpect.io"
                xmlns:functx="http://www.functx.com"
                exclude-result-prefixes="xs" 
                xpath-default-namespace="http://www.w3.org/1998/Math/MathML"
                version="2.0">
    
  <!-- This stylesheet is used to convert simple MathML expressions to plain text,
       e.g. "a+2", "a²", "+3".
       
       This could be useful if you want to reduce the number of equations 
       in your output, for instance to decrease page load time.
  
       Invoke on command line with saxon:
       $ saxon -xsl:xsl/unwrap-mml.xsl -s:source.xml -o:output.xml
  -->
    
  <xsl:strip-space elements="mml:*"/>
  
  <!-- wrapper element -->
  <xsl:param name="wrapper" as="element()?">
    <phrase role="flattened-mml" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <!-- create elements for different styles. You may override this in your 
       importing stylesheet to satisfy other XML schemas -->
  <xsl:param name="superscript" as="element()?">
    <superscript xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <xsl:param name="subscript" as="element()?">
    <subscript xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <xsl:param name="bold" as="element()?">
    <phrase role="bold" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <xsl:param name="italic" as="element()?">
    <phrase role="italic" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <xsl:param name="bold-italic" as="element()?">
    <phrase role="bold-italic" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>

  <xsl:param name="flatten-display-equations" select="true()" as="xs:boolean"/>
 
  <!-- if the number of operators (except those containing whitespace and parentheses) 
       exceed this limit, the equation will not be flattened -->
  <xsl:param name="operator-limit" select="1" as="xs:integer"/>

  <xsl:param name="whitespace-wrapper-for-operators" select="''" as="xs:string*"/>

  <xsl:variable name="whitespace-regex" select="'[\n\p{Zs}&#x200b;-&#x200f;]'" as="xs:string"/>

  <xsl:variable name="parenthesis-regex" select="'[\[\]\(\){}&#x2308;&#x2309;&#x230a;&#x230b;&#x2329;&#x232a;&#x27e8;&#x27e9;&#x3008;&#x3009;]'" as="xs:string"/>

  <xsl:variable name="math-alphanums" as="element()+">
    <alphanums>
      <alphanum name="serif-bold">𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳</alphanum>
      <alphanum name="serif-italic">𝐴𝐵𝐶𝐷𝐸𝐹𝐺𝐻𝐼𝐽𝐾𝐿𝑀𝑁𝑂𝑃𝑄𝑅𝑆𝑇𝑈𝑉𝑊𝑋𝑌𝑍𝑎𝑏𝑐𝑑𝑒𝑓𝑔𝑖𝑗𝑘𝑙𝑚𝑛𝑜𝑝𝑞𝑟𝑠𝑡𝑢𝑣𝑤𝑥𝑦𝑧</alphanum>
      <alphanum name="serif-bold-italic">𝑨𝑩𝑪𝑫𝑬𝑭𝑮𝑯𝑰𝑱𝑲𝑳𝑴𝑵𝑶𝑷𝑸𝑹𝑺𝑻𝑼𝑽𝑾𝑿𝒀𝒁𝒂𝒃𝒄𝒅𝒆𝒇𝒈𝒉𝒊𝒋𝒌𝒍𝒎𝒏𝒐𝒑𝒒𝒓𝒔𝒕𝒖𝒗𝒘𝒙𝒚𝒛</alphanum>
      <alphanum name="fraktur">𝔄𝔅ℭ𝔇𝔈𝔉𝔊ℌℑ𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔ℜ𝔖𝔗𝔘𝔙𝔚𝔛𝔜ℨ𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷</alphanum>
      <alphanum name="script">𝒜ℬ𝒞𝒟ℰℱ𝒢ℋℐ𝒥𝒦ℒℳ𝒩𝒪𝒫𝒬ℛ𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵𝒶𝒷𝒸𝒹ℯ𝒻ℊ𝒽𝒾𝒿𝓀ℓ𝓁𝓂𝓃𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏</alphanum>
      <alphanum name="double-struck">𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤ𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕟𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫</alphanum>
      <alphanum name="bold-fraktur">𝕬𝕭𝕮𝕯𝕰𝕱𝕲𝕳𝕴𝕵𝕶𝕷𝕸𝕹𝕺𝕻𝕼𝕽𝕾𝕿𝖀𝖁𝖂𝖃𝖄𝖅𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟</alphanum>
      <alphanum name="bold-script">𝓐𝓑𝓒𝓓𝓔𝓕𝓖𝓗𝓘𝓙𝓚𝓛𝓜𝓝𝓞𝓟𝓠𝓡𝓢𝓣𝓤𝓥𝓦𝓧𝓨𝓩𝓪𝓫𝓬𝓭𝓮𝓯𝓰𝓱𝓲𝓳𝓴𝓵𝓶𝓷𝓸𝓹𝓺𝓻𝓼𝓽𝓾𝓿𝔀𝔁𝔂𝔃</alphanum>
      <alphanum name="sans-serif">𝖠𝖡𝖢𝖣𝖤𝖥𝖦𝖧𝖨𝖩𝖪𝖫𝖬𝖭𝖮𝖯𝖰𝖱𝖲𝖳𝖴𝖵𝖶𝖷𝖸𝖹𝖺𝖻𝖼𝖽𝖾𝖿𝗀𝗁𝗂𝗃𝗄𝗅𝗆𝗇𝗈𝗉𝗊𝗋𝗌𝗍𝗎𝗏𝗐𝗑𝗒𝗓</alphanum>
      <alphanum name="sans-serif-bold">𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇</alphanum>
      <alphanum name="sans-serif-italic">𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻</alphanum>
      <alphanum name="sans-serif-bold-italic">𝘼𝘽𝘾𝘿𝙀𝙁𝙂𝙃𝙄𝙅𝙆𝙇𝙈𝙉𝙊𝙋𝙌𝙍𝙎𝙏𝙐𝙑𝙒𝙓𝙔𝙕𝙖𝙗𝙘𝙙𝙚𝙛𝙜𝙝𝙞𝙟𝙠𝙡𝙢𝙣𝙤𝙥𝙦𝙧𝙨𝙩𝙪𝙫𝙬𝙭𝙮𝙯</alphanum>
      <alphanum name="monospace">𝙰𝙱𝙲𝙳𝙴𝙵𝙶𝙷𝙸𝙹𝙺𝙻𝙼𝙽𝙾𝙿𝚀𝚁𝚂𝚃𝚄𝚅𝚆𝚇𝚈𝚉𝚊𝚋𝚌𝚍𝚎𝚏𝚐𝚑𝚒𝚓𝚔𝚕𝚖𝚗𝚘𝚙𝚚𝚛𝚜𝚝𝚞𝚟𝚠𝚡𝚢𝚣</alphanum>
      <alphanum name="greek">ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡϴΣΤΥΦΧΨΩ∇αβγδεζηθικλμνξοπρςστυφχψω∂εϑϰϕρϖ</alphanum>
      <alphanum name="greek-bold">𝚨𝚩𝚪𝚫𝚬𝚭𝚮𝚯𝚰𝚱𝚲𝚳𝚴𝚵𝚶𝚷𝚸𝚹𝚺𝚻𝚼𝚽𝚾𝚿𝛀𝛁𝛂𝛃𝛄𝛅𝛆𝛇𝛈𝛉𝛊𝛋𝛌𝛍𝛎𝛏𝛐𝛑𝛒𝛓𝛔𝛕𝛖𝛗𝛘𝛙𝛚𝛛𝛜𝛝𝛞𝛟𝛠𝛡</alphanum>
      <alphanum name="greek-italic">𝛢𝛣𝛤𝛥𝛦𝛧𝛨𝛩𝛪𝛫𝛬𝛭𝛮𝛯𝛰𝛱𝛲𝛳𝛴𝛵𝛶𝛷𝛸𝛹𝛺𝛻𝛼𝛽𝛾𝛿𝜀𝜁𝜂𝜃𝜄𝜅𝜆𝜇𝜈𝜉𝜊𝜋𝜌𝜍𝜎𝜏𝜐𝜑𝜒𝜓𝜔𝜕𝜖𝜗𝜘𝜙𝜚𝜛</alphanum>
      <alphanum name="greek-bold-italic">𝜜𝜝𝜞𝜟𝜠𝜡𝜢𝜣𝜤𝜥𝜦𝜧𝜨𝜩𝜪𝜫𝜬𝜭𝜮𝜯𝜰𝜱𝜲𝜳𝜴𝜵𝜶𝜷𝜸𝜹𝜺𝜻𝜼𝜽𝜾𝜿𝝀𝝁𝝂𝝃𝝄𝝅𝝆𝝇𝝈𝝉𝝊𝝋𝝌𝝍𝝎𝝏𝝐𝝑𝝒𝝓𝝔𝝕</alphanum>
      <alphanum name="greek-sans-serif-bold">𝝖𝝗𝝘𝝙𝝚𝝛𝝜𝝝𝝞𝝟𝝠𝝡𝝢𝝣𝝤𝝥𝝦𝝧𝝨𝝩𝝪𝝫𝝬𝝭𝝮𝝯𝝰𝝱𝝲𝝳𝝴𝝵𝝶𝝷𝝸𝝹𝝺𝝻𝝼𝝽𝝾𝝿𝞀𝞁𝞂𝞃𝞄𝞅𝞆𝞇𝞈𝞉𝞊𝞋𝞌𝞍𝞎𝞏</alphanum>
      <alphanum name="greek-sans-serif-bold-italic">𝞐𝞑𝞒𝞓𝞔𝞕𝞖𝞗𝞘𝞙𝞚𝞛𝞜𝞝𝞞𝞟𝞠𝞡𝞢𝞣𝞤𝞥𝞦𝞧𝞨𝞩𝞪𝞫𝞬𝞭𝞮𝞯𝞰𝞱𝞲𝞳𝞴𝞵𝞶𝞷𝞸𝞹𝞺𝞻𝞼𝞽𝞾𝞿𝟀𝟁𝟂𝟃𝟄𝟅𝟆𝟇𝟈𝟉</alphanum>
      <alphanum name="digit-bold">𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗</alphanum>
      <alphanum name="digit-double-struck">𝟘𝟙𝟚𝟛𝟜𝟝𝟞𝟟𝟠𝟡</alphanum>
      <alphanum name="digit-sans-serif">𝟢𝟣𝟤𝟥𝟦𝟧𝟨𝟩𝟪𝟫</alphanum>
      <alphanum name="digit-sans-serif-bold">𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵</alphanum>
      <alphanum name="digit-monospace">𝟶𝟷𝟸𝟹𝟺𝟻𝟼𝟽𝟾𝟿</alphanum>
    </alphanums>
  </xsl:variable>
  
  <xsl:variable name="math-spaces" as="element()">
    <spaces>
      <space name="veryverythinmathspace">&#x200a;</space>
      <space name="verythinmathspace">&#x200a;</space>
      <space name="thinmathspace">&#x2002;</space>
      <space name="mediummathspace">&#x2006;</space>
      <space name="thickmathspace">&#x2005;</space>
      <space name="verythickmathspace">&#x2004;</space>
      <space name="veryverythickmathspace">&#x2002;</space>
      <!-- to-do: handle negative spaces -->
      <space name="negativeveryverythinmathspace"></space>
      <space name="negativeverythinmathspace"></space>
      <space name="negativethinmathspace"></space>
      <space name="negativemediummathspace"></space>
      <space name="negativethickmathspace"></space>
      <space name="negativeverythickmathspace"></space>
      <space name="negativeveryverythickmathspace"></space>        
    </spaces>
  </xsl:variable>

  <xsl:variable name="fractions" as="element()+">
    <fractions>
      <frac value="1/2">½</frac>
      <frac value="0/3">↉</frac>
      <frac value="1/3">⅓</frac>
      <frac value="2/3">⅔</frac>
      <frac value="1/4">¼</frac>
      <frac value="3/4">¾</frac>
      <frac value="1/5">⅕</frac>
      <frac value="2/5">⅖</frac>
      <frac value="3/5">⅗</frac>
      <frac value="4/5">⅘</frac>
      <frac value="1/6">⅙</frac>
      <frac value="5/6">⅚</frac>
      <frac value="1/7">⅐</frac>
      <frac value="1/8">⅛</frac>
      <frac value="3/8">⅜</frac>
      <frac value="5/8">⅝</frac>
      <frac value="7/8">⅞</frac>
      <frac value="1/9">⅑</frac>
      <frac value="1/10">⅒</frac>
    </fractions>
  </xsl:variable>

  <xsl:template match="math[every $i in .//*
                            satisfies (string-length(normalize-space($i)) eq 0 and not($i/@*))]" mode="mml2tex-preprocess">
    <xsl:message select="'[WARNING] empty equation removed:&#xa;', ."/>
  </xsl:template>

  <xsl:template match="math[tr:unwrap-mml-boolean(.)]">
    <xsl:choose>
      <xsl:when test="$wrapper">
        <xsl:element name="{$wrapper/local-name()}" namespace="{$wrapper/namespace-uri()}">
          <xsl:apply-templates select="$wrapper/@*" mode="#default"/>
          <xsl:apply-templates mode="unwrap-mml"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="unwrap-mml"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="unwrap-mml">
    <xsl:apply-templates mode="unwrap-mml"/>
  </xsl:template>
  
  <xsl:template match="msub|msup" mode="unwrap-mml">
    <xsl:variable name="element" select="if(local-name() eq 'msub') then $subscript else $superscript" as="element()?"/>
    <xsl:apply-templates select="*[1]" mode="unwrap-mml"/>
    <xsl:choose>
      <xsl:when test="empty($element) and matches(*[2], '^\d+$')">
        <xsl:value-of select="translate(*[2],
                                        '0123456789',
                                        if(local-name() eq 'msub') 
                                        then '₀₁₂₃₄₅₆₇₈₉'
                                        else '⁰¹²³⁴⁵⁶⁷⁸⁹'
                                        )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$element/local-name()}" namespace="{$element/namespace-uri()}">
          <xsl:apply-templates select="$element/@*" mode="#default"/>
          <xsl:apply-templates select="*[2]" mode="unwrap-mml"/>
        </xsl:element>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mi[string-length() eq 1 and not(@mathvariant) or @mathvariant = ('italic', '')]" mode="unwrap-mml" priority="2">
    <xsl:call-template name="conditionally-replace-chars">
      <xsl:with-param name="element" select="$italic"/>
      <xsl:with-param name="style" select="'italic'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('mi', 'mo', 'mn', 'mtext')][@mathvariant = ('italic',
                                                                                     'bold',
                                                                                     'bold-italic',
                                                                                     'fraktur',
                                                                                     'script',
                                                                                     'double-struck',
                                                                                     'bold-fraktur',
                                                                                     'bold-script',
                                                                                     'sans-serif',
                                                                                     'sans-serif-bold',
                                                                                     'sans-serif-italic',
                                                                                     'sans-serif-bold-italic',
                                                                                     'monospace')]" mode="unwrap-mml">
    <xsl:variable name="style" select="@mathvariant" as="xs:string"/>
    <xsl:variable name="element" select="if($style eq 'italic') then $italic
                                         else if($style eq 'bold') then $bold 
                                         else if($style eq 'bold-italic') then $bold-italic 
                                         else ()" as="element()?"/>
    <xsl:call-template name="conditionally-replace-chars">
      <xsl:with-param name="element" select="$element"/>
      <xsl:with-param name="style" select="$style"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="conditionally-replace-chars">
    <xsl:param name="element" as="element()?"/>
    <xsl:param name="style" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$style = ('italic', 'bold', 'bold-italic') and exists($element)">
        <xsl:element name="{$element/local-name()}" namespace="{$element/namespace-uri()}">
          <xsl:apply-templates select="$element/@*" mode="#default"/>
          <xsl:apply-templates select="node()" mode="unwrap-mml"/>
        </xsl:element>
      </xsl:when>     
      <xsl:when test="matches(., '^[0-9]+$')">
        <xsl:value-of select="translate(., 
                                        '01234556789', 
                                         $math-alphanums/*:alphanum[@name eq concat('digit-', $style)])"/>
      </xsl:when>
      <xsl:when test="matches(., concat('^[', $math-alphanums/*:alphanum[@name eq 'greek'], ']$'))">
        <xsl:value-of select="translate(., 
                                        $math-alphanums/*:alphanum[@name eq 'greek'], 
                                        $math-alphanums/*:alphanum[@name eq concat('greek-', $style)])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(., 
                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 
                                        $math-alphanums/*:alphanum[@name eq $style])"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mspace" mode="unwrap-mml">
    <xsl:variable name="width" select="xs:decimal(replace(@width, '[a-z]+', ''))" as="xs:decimal"/>
    <xsl:variable name="mu-width" select="$width * 18" as="xs:decimal"/>
    <!-- 1 mu = 1/18em, MathML authors are encouraged to use em as unit here -->
    <xsl:variable name="text-mwidth" 
                  select="     if($mu-width &lt;   0)  then ''                 (: remove negative witdh :)
                          else if($mu-width &gt;= 36)  then '&#x2003;&#x2003;' (: twice of \quad (= 36 mu):)
                          else if($mu-width &gt;= 18)  then '&#x2003;'         (: 1 mu :)
                          else if($mu-width &gt;=  9)  then '&#x20;'           (: equivalent of space in normal text :)
                          else if($mu-width &gt;=  5)  then '&#x2004;'         (: 5/18 of \quad (= 5 mu) :)
                          else if($mu-width &gt;=  4)  then '&#x2005;'         (: 4/18 of \quad (= 3 mu) :)
                          else if($mu-width &lt;   4)  then '&#x2009;'         (: 3/18 of \quad (= 3 mu) :)
                                                       else '&#x20;'" as="xs:string"/>
    <xsl:value-of select="$text-mwidth"/>
  </xsl:template>
  
  <xsl:template match="mo[matches(., '&#x2061;') and @rspace]" mode="unwrap-mml">
    <xsl:variable name="space-name" select="@rspace" as="attribute(rspace)"/>
    <xsl:value-of select="$math-spaces[@name eq $space-name]"/>    
  </xsl:template>
  
  <xsl:template match="mo" mode="unwrap-mml">
    <xsl:variable name="whitespace-boolean" select="    not(matches(., $whitespace-regex))
                                                    and not(ancestor::msup or ancestor::msub or ancestor::msubsup)
                                                    and (not(parent::math))
                                                    and not(not(preceding-sibling::*[1]) and . = ('+', '-', '∓', '±'))
                                                    " as="xs:boolean"/>
    <xsl:variable name="whitespace" select="if($whitespace-boolean and not(matches(., $parenthesis-regex))) 
                                            then $whitespace-wrapper-for-operators 
                                            else ''" as="xs:string?"/>
    <xsl:value-of select="concat(if(preceding-sibling::*[1]) then $whitespace else '', 
                                 translate(., '-/', '&#x2212;&#x2215;'), 
                                 $whitespace)"/>
  </xsl:template>
  
  <xsl:template match="mfrac[string-join(*, '/') = $fractions//*:frac/@value]" mode="unwrap-mml">
    <xsl:variable name="frac-value" select="string-join(*, '/')"/>
    <xsl:variable name="unicode-frac" select="$fractions/*:frac[@value eq $frac-value]" as="xs:string"/>
    <xsl:value-of select="$unicode-frac"/>
  </xsl:template>
  
  <xsl:template match="mfenced" mode="unwrap-mml">
    <xsl:variable name="seps" select="@separators" as="attribute(separators)?"/>
    <xsl:value-of select="(@open, '(')[1]"/>
    <xsl:for-each select="*">
      <xsl:variable name="elm" select="." as="element()"/>
      <xsl:variable name="pos" select="position()"/>
      <xsl:apply-templates select="$elm" mode="#current"/> 
      <xsl:value-of select="     if(not($pos eq last()) and $seps)
                              then (functx:chars($seps)[$pos], '')[1]
                            else if (not($pos eq last()) and not($seps))
                              then ','
                            else ''"/>
    </xsl:for-each>
    <xsl:value-of select="(@close, ')')[1]"/>
  </xsl:template>
  
  <xsl:function name="functx:chars" as="xs:string*">
    <xsl:param name="arg" as="xs:string?"/>
    
    <xsl:sequence select="for $ch in string-to-codepoints($arg)
                          return codepoints-to-string($ch)"/>
  </xsl:function>
  
  <xsl:function name="tr:unwrap-mml-boolean" as="xs:boolean">
    <xsl:param name="math" as="element(math)"/>
    <xsl:value-of select="count($math//mo[not(matches(., concat('^', $whitespace-regex, '|', $parenthesis-regex, '$')))]) le $operator-limit
                          and not(   $math//mfrac[not(string-join(*, '/') = $fractions//*:frac/@value)] 
                                  or $math//mroot
                                 or $math//msqrt
                                 or $math//mtable
                                 or $math//mmultiscripts
                                 or $math//mphantom
                                 or $math//mstyle
                                 or $math//mover
                                 or $math//munder
                                 or $math//munderover
                                 or $math//msubsup
                                 or $math//menclose
                                 or $math//merror
                                 or $math//maction
                                 or $math//mglyph
                                 or $math//mlongdiv
                                 or $math//msup[.//msub|.//msup|.//msubsup]
                                 or $math//msub[.//msub|.//msup|.//msubsup]
                                 or $math//msubsup[.//msub|.//msup|.//msubsup]
                                 )
                          and (($math[@display eq 'block'] 
                               and $flatten-display-equations ) 
                               or $math[@display ne 'block' or not(@display)])"/>
  </xsl:function>

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template> 
  
</xsl:stylesheet>
