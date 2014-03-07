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
  <!-- text copying -->
  <xsl:template mode="text" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template mode="text" match="span[@class = 'c6']">
    <emphasis><xsl:apply-templates mode="text"/></emphasis>
  </xsl:template>
  <xsl:template mode="text" match="span[@class = 'c16']">
    <emphasis><xsl:apply-templates mode="text"/></emphasis>
  </xsl:template>
</xsl:stylesheet>
