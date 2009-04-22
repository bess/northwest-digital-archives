<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output indent="yes"/>
    <xsl:template match="/">
        <add>
            <doc>
                <xsl:call-template name="id"/>
                <xsl:call-template name="title"/>
                <xsl:call-template name="publisher"/>
                <xsl:call-template name="subject"/>
            </doc>
        </add>
    </xsl:template>
    
    <!-- This id should be unique -->
    <xsl:template name="id">
        <field name="id"><xsl:value-of select="/ead/eadheader/eadid/text()"/></field>
    </xsl:template>
    
    <xsl:template name="title">
        <field name="title_display"><xsl:value-of select="/ead/eadheader/filedesc/titlestmt/titleproper[1]/text()"/></field>
    </xsl:template>
    
    <xsl:template name="publisher">
        <field name="publisher_facet"><xsl:value-of select="/ead/eadheader/filedesc/publicationstmt/publisher/text()"/></field>
    </xsl:template>
    
    <xsl:template name="subject">
        <xsl:for-each select="//persname|famname|corpname[@role='subject']/text()">
            <field name="subject_facet"><xsl:value-of select="."/></field>
        </xsl:for-each>
        
        <xsl:for-each select="//subject/text()">
            <field name="subject_facet"><xsl:value-of select="."/></field>
        </xsl:for-each>
        
        <xsl:for-each select="//geogname/text()">
            <field name="geographic_subject_facet"><xsl:value-of select="."/></field>
        </xsl:for-each>
        
    </xsl:template>
    
</xsl:stylesheet>
