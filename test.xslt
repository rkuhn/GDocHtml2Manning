<?xml version="1.0"?>
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:x="http://rkuhn.info/x" version="1.0">
  <output method="xml" indent="yes"/>
  <template match="node()"><copy><for-each select="@*"><copy/></for-each><apply-templates/></copy></template>
  <template match="style/text()">
    <call-template name="css2xml">
      <with-param name="text" select="."/>
      <with-param name="pattern">font-weight:bold</with-param>
    </call-template>
  </template>
  <template name="css2xml">
    <param name="text"/>
    <param name="pattern"/>
    <if test="$text">
      <variable name="key" select="substring-before($text, '{')"/>
      <variable name="rest" select="substring-after($text, '{')"/>
      <variable name="value" select="substring-before($rest, '}')"/>
      <choose>
        <when test="$value = $pattern"><value-of select="$value"/></when>
        <otherwise>
          <call-template name="css2xml">
            <with-param name="text" select="substring-after($rest, '}')"/>
            <with-param name="pattern" select="$pattern"/>
          </call-template>
        </otherwise>
      </choose>
    </if>
  </template>
</stylesheet>
