<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:lxir="http://www.latex-lxir.org"
	xmlns:mathml="http://www.w3.org/1998/Math/MathML"
	exclude-result-prefixes="lxir mathml">
	<!--xmlns="http://www.w3.org/1999/xhtml"-->
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8"
	            doctype-system="about:legacy-compat"
	            omit-xml-declaration = "yes"/>
	
	<xsl:preserve-space elements="text"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:variable name="toc-maxlevel" select="1"/>
	
	<xsl:template match="/document">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>A C++ draft formatting test</title>
				<!--<script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js?lang=Cpp"></script>-->
				<script src="bower_components/platform/platform.js"><xsl:comment> </xsl:comment></script>
				<link rel="import" href="bower_components/cxx-html-doc-framework/framework.html"/>
				<!--<link rel="stylesheet" type="text/css" href="cpp-draft.css"/>-->
			</head>
			<body>
				<xsl:attribute name="onload"><![CDATA[document.querySelectorAll('*').array().forEach( function(node){ if (node.checkInvariants) node.checkInvariants(); });]]></xsl:attribute>
				<cxx-toc><xsl:comment> </xsl:comment></cxx-toc>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="heading">
		<xsl:param name="heading-node"/>
		
		<xsl:element name="{concat('h',1+@level)}">
			<xsl:apply-templates select="$heading-node" mode="heading"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="generalized-section">
		<xsl:param name="heading-node"/>
		<xsl:param name="intern-template"/>
		
		<xsl:choose>
			<xsl:when test="@level = 0">
				<cxx-clause id="{@id}">
					<xsl:call-template name="heading">
						<xsl:with-param name="heading-node" select="$heading-node"/>
					</xsl:call-template>
					
					<xsl:apply-templates select="." mode="section-intern"/>
				</cxx-clause>
			</xsl:when>
			
			<xsl:otherwise>
				<cxx-section id="{@id}">
					<xsl:call-template name="heading">
						<xsl:with-param name="heading-node" select="$heading-node"/>
					</xsl:call-template>
					
					<xsl:apply-templates select="." mode="section-intern"/>
				</cxx-section>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="section">
		<xsl:call-template name="generalized-section">
			<xsl:with-param name="heading-node" select="title"/>
			<xsl:with-param name="intern-template" select="'section-intern'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="section" mode="section-intern">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="section/title"/>
	<xsl:template match="section/title" mode="heading">
		<xsl:apply-templates select="* | text()"/>
	</xsl:template>
	
	<xsl:template match="definition">
		<!-- maybe use <dl is="cxx-definition-dection"> ?? -->
		<xsl:call-template name="generalized-section">
			<xsl:with-param name="heading-node" select="./defines"/>
			<xsl:with-param name="intern-template" select="'definition-intern'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="definition" mode="section-intern">
		<xsl:if test="alt-name">
			<div class="alt-name">
				<xsl:text>Also called:</xsl:text>
				<ul class="alt-name">
					<xsl:apply-templates select="alt-name"/>
				</ul>
			</div>
		</xsl:if>
		
		<xsl:apply-templates select="explanation"/>
		
		<xsl:apply-templates select="*[name() != 'alt-name' and name() != 'explanation'] | text()"/>
	</xsl:template>
	<xsl:template match="definition/defines" mode="heading">
		<xsl:apply-templates select="* | text()"/>
	</xsl:template>
	<xsl:template match="definition/defines"/>
	<xsl:template match="definition/alt-name">
		<li>
			<xsl:apply-templates select="@* | * | text()"/>
		</li>
	</xsl:template>
	<xsl:template match="definition/explanation">
		<div class="explanation">
			<xsl:apply-templates select="@* | * | text()"/>
		</div>
	</xsl:template>
	
	<xsl:template match="par[@number]">
		<div class="numbered-paragraph" id="{concat(ancestor::*[@id][1]/@id, '/', @number)}">
			<span class="par-number"><xsl:value-of select="@number"/></span>
			<xsl:apply-templates select="*"/>
		</div>
	</xsl:template>
	
	<!-- some sections have introductory paragraphs such as a bnf in [expr.prim.general]
	     which have no numbers but can reasonably be seen as paragraphs (structurally) -->
	<xsl:template match="par[not(@number) and name(ancestor::*[1]) = 'section' and name(preceding-sibling::*[1]) = 'title']">
		<div class="numbered-paragraph">
			<xsl:apply-templates select="@* | * | text()"/>
		</div>
	</xsl:template>
	<xsl:template match="par[not(@number) and ancestor::footnotelist]">
		<div class="footnote-par">
			<xsl:apply-templates select="@* | * | text()"/>
		</div>
	</xsl:template>
	
	<xsl:template match="minipage-block">
		<div class="minipage-block">
			<xsl:apply-templates select="@* | * | text()"/>
		</div>
	</xsl:template>
	<xsl:template match="minipage-block/minipage">
		<div class="minipage">
			<xsl:apply-templates select="*"/>
		</div>
	</xsl:template>
	
	<xsl:template match="text" name="text-element">
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:template>
	
	
	<xsl:template match="mathml:math">
		<xsl:copy>
			<xsl:apply-templates mode="math" select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="mathml:math/@type" mode="math">
		<xsl:attribute name="display"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	
	<xsl:template match="sub[count(*) = 1 and ./mathml:math] | sup[count(*) = 1 and ./mathml:math]">
		<xsl:copy>
			<xsl:apply-templates mode="math" select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@* | * | text()" mode="math">
		<xsl:copy>
			<xsl:apply-templates mode="math" select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>

	
	<xsl:template match="bnftab">
		<xsl:choose>
			<xsl:when test="count(defines/*) > 0">
				<dl class="{@type}">
					<xsl:apply-templates select="@* | * | text()"/>
				</dl>
			</xsl:when>
			<xsl:otherwise>
				<ul class="{@type}">
					<xsl:apply-templates select="@* | * | text()"/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="bnfkeywordtab">
		<dl class="{name()}">
			<xsl:apply-templates select="defines"/>
			<dd><table><tbody>
				<xsl:apply-templates select="line-hint"/>
			</tbody></table></dd>
		</dl>
	</xsl:template>
	
	<xsl:template match="bnf">
		<bnf-grammar>
			<xsl:apply-templates select="*"/>
		</bnf-grammar>
	</xsl:template>
	
	<xsl:template match="bnftab/defines | bnfkeywordtab/defines">
		<xsl:if test="*">
			<dt><xsl:apply-templates select="@* | * | text()"/></dt>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="bnf/defines">
		<bnf-rule>
			<xsl:apply-templates select="*"/>
		</bnf-rule>
	</xsl:template>
	
	<xsl:template match="defines/nontermdef | defines/description | grammar-rule/description">
		<span class="{name()}"><xsl:apply-templates select="@* | * | text()"/></span>
	</xsl:template>

	<xsl:template match="bnfkeywordtab/line-hint">
		<tr>
			<xsl:apply-templates select="@* | * | text()"/>
		</tr>
	</xsl:template>
	<xsl:template match="bnfkeywordtab/line-hint/keyword">
		<td>
			<code class="keyword"><xsl:apply-templates select="@* | * | text()"/></code>
		</td>
	</xsl:template>
	
	<xsl:template match="bnftab/grammar-rule">
		<xsl:choose>
			<xsl:when test="../defines/*">
				<dd><xsl:apply-templates select="@* | * | text()"/></dd>
			</xsl:when>
			<xsl:otherwise>
				<li><xsl:apply-templates select="@* | * | text()"/></li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bnftab/grammar-rule/br-hint">
		<xsl:element name="br"/>
	</xsl:template>
	
	<xsl:template match="bnftab//indent">
		<span class="indent"><xsl:text> </xsl:text></span>
	</xsl:template>
	
	<xsl:template match="bnf/grammar-rule">
		<bnf-alt>
			<xsl:apply-templates select="*"/>
		</bnf-alt>
	</xsl:template>
	
	<xsl:template match="indented">
		<div class="indented">
			<xsl:apply-templates select="@* | * | text()"/>
		</div>
	</xsl:template>


	<xsl:template match="list">
		<xsl:choose>
			<!--<xsl:apply-templates select="@*[name() != 'type']"/>-->
			
			<xsl:when test="@type = 'enumerate'">
				<ol><xsl:apply-templates select="*"/></ol>
			</xsl:when>
			
			<xsl:when test="@type = 'itemize'">
				<ul><xsl:apply-templates select="*"/></ul>
			</xsl:when>
			
			<xsl:when test="@type = 'description'">
				<dl><xsl:apply-templates select="*"/></dl>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:text>[error: unknown list type]</xsl:text>
				<ul><xsl:apply-templates select="*"/></ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="list[@type = 'enumerate' or @type = 'itemize']/item">
		<li>
			<xsl:if test="itemMark">
				<xsl:attribute name="class">custom-itemMark</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="@* | * | text()"/>
		</li>
	</xsl:template>
	<xsl:template match="list[@type = 'description']/item">
		<dt><xsl:apply-templates select="@* | itemMark/@* | itemMark/* | itemMark/text()"/></dt>
		<dd><xsl:apply-templates select="itemMark/following-sibling::*"/></dd>
	</xsl:template>
	<xsl:template match="list/item/itemMark">
		<span class="itemMark"><xsl:apply-templates select="@* | * | text()"/></span>
	</xsl:template>
	<xsl:template match="list/item/@no-itemMark[. = 'true']">
		<xsl:attribute name="class">no-itemMark</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="list[@type = 'description']/item/br[name(preceding-sibling::*) = 'itemMark']"/>
	

	<xsl:template match="table">
		<table id="{@id}" is="cxx-table">
			<xsl:apply-templates select="*"/>
		</table>
	</xsl:template>
	
	<xsl:template match="table/caption">
		<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates select="* | text()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="table/continued-caption"/>
	
	<xsl:template match="table/tabular">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	<xsl:template match="table/tabular/columnsModel">
		<!-- let's drop it for now -->
	</xsl:template>
	
	<xsl:template match="table/tabular/rowGroup">
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:template>
	
	<xsl:template match="table/tabular/rowGroup/tableHeader">
		<xsl:if test="not(@headType) or @headType != 'continued'">
			<thead>
				<xsl:apply-templates select="@* | * | text()"/>
			</thead>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="table/tabular/rowGroup/row | table/tabular/rowGroup/tableHeader/row">
		<tr>
			<xsl:apply-templates select="@* | * | text()"/>
		</tr>
	</xsl:template>

	<xsl:template match="row/cell | row/multicolumn/cell">
		<xsl:if test="not(@multirow-target)">
			<td>
				<xsl:if test="multirow">
					<xsl:attribute name="rowspan"><xsl:value-of select="multirow/@rows"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="name(..) = 'multicolumn'">
					<xsl:attribute name="colspan"><xsl:value-of select="../@columns"/></xsl:attribute>
				</xsl:if>
				
				<xsl:apply-templates select="*"/>
				
				<xsl:if test="not(*)">
					<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text><!-- todo: do that correctly.. -->
				</xsl:if>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="table/tabular/rowGroup/row/cell/multirow | table/tabular/rowGroup/tableHeader/row/cell/multirow">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="table/tabular/rowGroup/row/multicolumn | table/tabular/rowGroup/tableHeader/row/multicolumn">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	<xsl:template match="table/tabular/rowGroup/row/multicolumn | table/tabular/rowGroup/tableHeader/multirow">
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="cpp"><xsl:text>C++</xsl:text></xsl:template>	
	
	<xsl:template match="bnf//opt">
		<bnf-opt/>
	</xsl:template>
	<xsl:template match="opt">
		<span class="opt">opt</span>
	</xsl:template>
	
	<xsl:template match="uniquens">
		<span class="uniquens"><xsl:text>unique </xsl:text></span><!-- the space isn't perfect, but helps -->
	</xsl:template>
	
	<xsl:template match="cvqual">
		<span class="cvqual"><xsl:apply-templates select="@* | * | text()"/></span>
	</xsl:template>
	
	<xsl:template match="ICS">
		<xsl:element name="math">
			<xsl:attribute name="class">ICS</xsl:attribute>
			
			<xsl:element name="msub">
				<xsl:element name="mtext">ICS</xsl:element>
				<xsl:element name="mi"><xsl:value-of select="@index"/></xsl:element>
			</xsl:element>
			<xsl:element name="mo">(</xsl:element>
			<xsl:element name="mtext"><code class="inline"><xsl:value-of select="@arg"/></code></xsl:element>
			<xsl:element name="mo">)</xsl:element>
		</xsl:element>
	</xsl:template>

	
	<xsl:template match="figure">
		<xsl:copy>
			<xsl:apply-templates select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="figure/caption">
		<figcaption>
			<xsl:value-of select="../@position"/>
			<xsl:text> - </xsl:text>
			<xsl:apply-templates select="@* | * | text()"/>
		</figcaption>
	</xsl:template>
	
	<xsl:template match="importgraphic">
		<xsl:apply-templates select="@*"/>
		<div style="width: 90%; border: solid 1px black; display: block; margin: 1em auto 1em auto; text-align: center; padding: 1em 0 1em 0;">graphic placeholder for <xsl:value-of select="."/></div>
	</xsl:template>

	
	<xsl:template match="ref">
		<xsl:variable name="own-idref" select="@idref"/>
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="concat('#', @idref)"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="//*[@id = $own-idref]">
					<xsl:attribute name="class">ref</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">ref-broken</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="@idref"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:key name="custom-id" match="//footnote" use="@id"/>
	<xsl:template match="footnoteCall">
		<cxx-footnote><xsl:apply-templates select="key('custom-id', @idref)/footnoteText/*"/></cxx-footnote>
	</xsl:template>
	<xsl:template match="footnoteText">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	<xsl:template match="bnf//terminal">
		<bnf-terminal>
			<xsl:apply-templates select="*"/>
		</bnf-terminal>
	</xsl:template>
	<xsl:template match="tcode | terminal">
		<code class="inline"> <!-- could pretty-print that too, but I don't think it's worth it -->
			<xsl:apply-templates select="@* | * | text()"/>
		</code>
	</xsl:template>
	
	<xsl:template match="emph">
		<em><xsl:apply-templates select="@* | * | text()"/></em>
	</xsl:template>
	
	<xsl:template match="logop | NTS | term">
		<span class="{name()}"><xsl:apply-templates select="@* | * | text()"/></span>
	</xsl:template>
	
	<xsl:template match="doccite">
		<cite class="doccite"><xsl:apply-templates select="@* | * | text()"/></cite>
	</xsl:template>
	
	<xsl:template match="grammarterm | nonterminal">
		<cxx-term class="{name()}"><xsl:apply-templates select="@* | * | text()"/></cxx-term>
	</xsl:template>
	
	<xsl:template match="placeholder | numconst">
		<var class="{name()}"><xsl:apply-templates select="@* | * | text()"/></var>
	</xsl:template>
	
	<xsl:template match="defnx">
		<dfn class="defnx"><xsl:apply-templates select="@* | * | text()"/></dfn>
	</xsl:template>

	
	<xsl:template match="codeblock">
		<cxx-codeblock>
			<xsl:apply-templates select="@* | * | text()"/>
		</cxx-codeblock>
	</xsl:template>


	<xsl:template name="non-mandatory-block">
		<xsl:param name="intro"/>
		<xsl:param name="outro"/>
		<xsl:param name="class"/>
		
		<div class="{$class}">
			<xsl:apply-templates select="@*"/>
			<xsl:text>[</xsl:text>
			
			<span class="non-mandatory-intro"><xsl:value-of select="$intro"/></span>
			
			<xsl:apply-templates select="*"/>
			
			<span class="non-mandatory-outro">
				<xsl:text disable-output-escaping="yes"><![CDATA[&mdash;]]></xsl:text>
				<xsl:text disable-output-escaping="yes"><![CDATA[-&nbsp;]]></xsl:text>
				<xsl:value-of select="$outro"/>
			</span>
			
			<xsl:text>]</xsl:text>
		</div>
	</xsl:template>	
	
	<xsl:template match="note">
		<cxx-note>
			<xsl:apply-templates select="*"/>
		</cxx-note>
	</xsl:template>
	
	<xsl:template match="example">
		<cxx-example>
			<xsl:apply-templates select="*"/>
		</cxx-example>
	</xsl:template>
	
	
	<xsl:template match="footnotelist"></xsl:template>
	
	
	<xsl:template match="/" mode="toc">
		<ul>
			<xsl:apply-templates mode="toc" select="*"/>
		</ul>
	</xsl:template>
	
	<xsl:template name="generalized-section-toc">
		<xsl:param name="heading-node"/>
		
		<xsl:variable name="class" select="concat('level', @level)"/>
		<li class="{$class}">
			<a class="toc" href="{concat('#', @id)}">
				<xsl:value-of select="@position"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates mode="toc-heading" select="$heading-node"/>
			</a>
			<xsl:if test="@level &lt; $toc-maxlevel and (count(.//section) + count(.//definition)) &gt; 0">
				<ul class="{$class}">
					<xsl:apply-templates select="*" mode="toc"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="section" mode="toc">
		<xsl:call-template name="generalized-section-toc">
			<xsl:with-param name="heading-node" select="title"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="section/title" mode="toc-heading">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="definition" mode="toc">
		<xsl:call-template name="generalized-section-toc">
			<xsl:with-param name="heading-node" select="./defines"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="definition/defines" mode="toc-heading">
		<xsl:apply-templates/>
	</xsl:template>
	
		
	<xsl:template match="*" mode="toc">
		<xsl:apply-templates mode="toc" select="*"/>
	</xsl:template>
	
	
	<xsl:template match="text()"><xsl:copy/></xsl:template>
	
	<xsl:template match="@id | @idref">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:template match="@*">
		<!--<xsl:attribute name="error">unknown attribute: <xsl:value-of select="name()"/></xsl:attribute>-->
	</xsl:template>
	<xsl:template match="*">
		<div class="error">
			<xsl:text>unknown element: [</xsl:text>
			<xsl:value-of select="name()"/>
			<xsl:text>]</xsl:text>
			<br/>
			<xsl:text>content:</xsl:text>
			<br/>
			<div class="error-content">
				<xsl:apply-templates select="@* | * | text()"/>
			</div>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
