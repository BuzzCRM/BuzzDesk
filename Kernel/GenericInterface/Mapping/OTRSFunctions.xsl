<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:func="http://exslt.org/functions"
                xmlns:otrs="http://otrs.org"
                xmlns:buzzdesk="http://buzzdesk.org"
                extension-element-prefixes="func otrs buzzdesk">

<xsl:import href="BuzzDeskFunctions.xsl" />

<!-- Deprecated: use BuzzDeskFunctions.xsl (buzzdesk:*) instead. -->
<func:function name="otrs:date-xsd-to-iso">
    <xsl:param name="date-time" />
    <func:result select="buzzdesk:date-xsd-to-iso($date-time)" />
</func:function>

<!-- Deprecated: use BuzzDeskFunctions.xsl (buzzdesk:*) instead. -->
<func:function name="otrs:date-iso-to-xsd">
    <xsl:param name="date-time" />
    <func:result select="buzzdesk:date-iso-to-xsd($date-time)" />
</func:function>

</xsl:stylesheet>
