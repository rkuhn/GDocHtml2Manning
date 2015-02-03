<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.manning.com/schemas/book" xsi:schemaLocation="http://www.manning.com/schemas/book manning-book.xsd" version="1.0">
  <xsl:output method="xml" indent="yes"/>
  <!-- switch off default processing rules -->
  <xsl:template match="text()|@*"/>
  <xsl:template mode="heading" match="text()|@*"/>
  <xsl:template match="*"/>
  <xsl:template mode="text" match="*">
    <xsl:message>unknown element type <xsl:value-of select="name(.)"/></xsl:message>
  </xsl:template>
  <xsl:template mode="code" match="*">
    <xsl:message>unknown element type <xsl:value-of select="name(.)"/></xsl:message>
  </xsl:template>
  <!-- top-level processing rule -->
  <xsl:template match="html">
    <chapter>
      <title><xsl:copy-of select="body/p[1]//text()"/></title>
      <xsl:apply-templates select="body/p[position() = 1]"/>
      <xsl:apply-templates mode="heading" select="body/h1"/>
    </chapter>
  </xsl:template>
  <xsl:template match="body/p">
    <xsl:apply-templates mode="text" select="."/>
    <xsl:call-template name="hh">
      <xsl:with-param name="l" select="1"/>
      <xsl:with-param name="n" select="1"/>
      <xsl:with-param name="emit" select="1"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="heading" match="h1|h2|h3|h4|h5|h6">
    <xsl:variable name="level" select="substring-after(name(), 'h')"/>
    <xsl:message>heading<xsl:value-of select="$level"/> <xsl:value-of select=".//text()"/></xsl:message>
    <xsl:element name="sect{$level}">
      <title><xsl:apply-templates mode="text"/></title>
      <xsl:call-template name="hh">
        <xsl:with-param name="l" select="$level"/>
        <xsl:with-param name="n" select="1"/>
        <xsl:with-param name="emit" select="1"/>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>
  <xsl:template name="hh">
    <xsl:param name="l"/>
    <xsl:param name="n"/>
    <xsl:param name="emit"/>
    <xsl:variable name="e" select="name(following-sibling::*[$n])"/>
    <xsl:variable name="rest" select="substring-after($e, 'h')"/>
    <xsl:if test="count(following-sibling::*) > $n and not(string-length($e) = 2 and starts-with($e, 'h') and number($rest) != 0 and $rest &lt;= $l)">
      <xsl:choose>
        <xsl:when test="$e = concat('h', $l + 1)">
          <xsl:apply-templates mode="heading" select="following-sibling::*[$n]"/>
          <xsl:call-template name="hh">
            <xsl:with-param name="l" select="$l"/>
            <xsl:with-param name="n" select="$n + 1"/>
            <xsl:with-param name="emit" select="0"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$emit = 1">
            <xsl:apply-templates mode="text" select="following-sibling::*[$n]"/>
          </xsl:if>
          <xsl:call-template name="hh">
            <xsl:with-param name="l" select="$l"/>
            <xsl:with-param name="n" select="$n + 1"/>
            <xsl:with-param name="emit" select="$emit"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- paragraphs -->
  <xsl:template mode="text" match="p">
    <para>
      <xsl:apply-templates mode="text"/>
    </para>
  </xsl:template>
  <!-- ignoring these -->
  <xsl:template mode="text" match="div"/>
  <xsl:template mode="text" match="span">
    <xsl:apply-templates mode="text"/>
  </xsl:template>
  <xsl:template mode="text" match="a[starts-with(@name, 'ftnt')]"/>
  <xsl:template mode="text" match="a">
    <xsl:apply-templates mode="text"/>
  </xsl:template>
  <xsl:template mode="text" match="hr"/>
  <xsl:template mode="text" match="br"/>
  <xsl:template mode="text" match="img"/>
  <!-- lists -->
  <xsl:template mode="text" match="ul">
    <itemizedlist>
      <xsl:apply-templates mode="text"/>
    </itemizedlist>
  </xsl:template>
  <xsl:template mode="text" match="ol">
    <orderedlist>
      <xsl:apply-templates mode="text"/>
    </orderedlist>
  </xsl:template>
  <xsl:template mode="text" match="li">
    <listitem>
      <para>
        <xsl:apply-templates mode="text"/>
      </para>
    </listitem>
  </xsl:template>
  <!-- footnotes -->
  <xsl:template mode="text" match="sup[./a]">
    <xsl:variable name="tag" select="substring-after(a/@href, '#')"/>
    <footnote>
      <xsl:apply-templates mode="text" select="/html/body/div/*[../p[1]/a[position() = 1 and @name = $tag]]"/>
    </footnote>
  </xsl:template>
  <!-- code snippets -->
  <xsl:template mode="text" match="p[./span[1]/@class]">
    <xsl:choose>
      <xsl:when test="span[1]/@class = $codefont">
        <xsl:choose>
          <xsl:when test="preceding-sibling::p[1]/span[1]/@class = $codefont"/>
          <xsl:otherwise>
            <informalexample>
              <programlisting>
                <xsl:apply-templates mode="code" select="span/*|span/text()"/>
                <xsl:apply-templates mode="code" select="following-sibling::p[1][span[1]/@class]"/>
              </programlisting>
            </informalexample>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <para>
          <xsl:apply-templates mode="text"/>
        </para>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="code" match="p">
    <xsl:if test="span[1]/@class = $codefont">
      <xsl:message>found extension <xsl:value-of select="span/text()"/></xsl:message>
      <xsl:text>
</xsl:text>
      <xsl:apply-templates mode="code" select="span/*|span/text()"/>
      <xsl:apply-templates mode="code" select="following-sibling::p[1][span/@class]"/>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="code" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template mode="code" match="br">
    <xsl:text>
</xsl:text>
  </xsl:template>
  <!-- text copying -->
  <xsl:template mode="text" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:variable name="codefont">
    <xsl:call-template name="css2xml">
      <xsl:with-param name="text" select="/html/head/style/text()"/>
      <xsl:with-param name="pattern">font-family:"Consolas"</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="bold">
    <xsl:call-template name="css2xml">
      <xsl:with-param name="text" select="/html/head/style/text()"/>
      <xsl:with-param name="pattern">font-weight:bold</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="italic">
    <xsl:call-template name="css2xml">
      <xsl:with-param name="text" select="/html/head/style/text()"/>
      <xsl:with-param name="pattern">font-style:italic</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:template mode="text" match="span[@class]">
    <xsl:choose>
      <xsl:when test="@class = $bold or @class = $italic">
        <emphasis><xsl:apply-templates mode="text"/></emphasis>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- find CSS tags -->
  <xsl:template name="css2xml">
    <xsl:param name="text"/>
    <xsl:param name="pattern"/>
    <xsl:if test="$text">
      <xsl:variable name="key" select="substring-before($text, '{')"/>
      <xsl:variable name="rest" select="substring-after($text, '{')"/>
      <xsl:variable name="value" select="substring-before($rest, '}')"/>
      <xsl:choose>
        <xsl:when test="$value = $pattern"><xsl:value-of select="substring-after($key, '.')"/></xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="css2xml">
            <xsl:with-param name="text" select="substring-after($rest, '}')"/>
            <xsl:with-param name="pattern" select="$pattern"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
