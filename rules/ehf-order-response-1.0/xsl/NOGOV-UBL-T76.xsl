<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:OrderResponse-2" version="2.0">
   
    <!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. v1.2 14.4.2014 -->
    
    <axsl:param name="archiveDirParameter" tunnel="no"/>
    <axsl:param name="archiveNameParameter" tunnel="no"/>
    <axsl:param name="fileNameParameter" tunnel="no"/>
    <axsl:param name="fileDirParameter" tunnel="no"/>
    
    <!--PHASES-->
    
    
    <!--PROLOG-->
    
    <axsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>
    
    <!--XSD TYPES-->
    
    
    <!--KEYS AND FUCNTIONS-->
    
    
    <!--DEFAULT RULES-->
    
    
    <!--MODE: SCHEMATRON-FULL-PATH-->
    <!--This mode can be used to generate an ugly though full XPath for locators-->
    
    <axsl:template match="*" mode="schematron-get-full-path">
        <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <axsl:text>/</axsl:text>
        <axsl:choose>
            <axsl:when test="namespace-uri()=''">
                <axsl:value-of select="name()"/>
            </axsl:when>
            <axsl:otherwise>
                <axsl:text>*:</axsl:text>
                <axsl:value-of select="local-name()"/>
                <axsl:text>[namespace-uri()='</axsl:text>
                <axsl:value-of select="namespace-uri()"/>
                <axsl:text>']</axsl:text>
            </axsl:otherwise>
        </axsl:choose>
        <axsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current()) and namespace-uri() = namespace-uri(current())])"/>
        <axsl:text>[</axsl:text>
        <axsl:value-of select="1+ $preceding"/>
        <axsl:text>]</axsl:text>
    </axsl:template>
    <axsl:template match="@*" mode="schematron-get-full-path">
        <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <axsl:text>/</axsl:text>
        <axsl:choose>
            <axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/></axsl:when>
            <axsl:otherwise>
                <axsl:text>@*[local-name()='</axsl:text>
                <axsl:value-of select="local-name()"/>
                <axsl:text>' and namespace-uri()='</axsl:text>
                <axsl:value-of select="namespace-uri()"/>
                <axsl:text>']</axsl:text>
            </axsl:otherwise>
        </axsl:choose>
    </axsl:template>
    
    <!--MODE: SCHEMATRON-FULL-PATH-2-->
    <!--This mode can be used to generate prefixed XPath for humans-->
    
    <axsl:template match="node() | @*" mode="schematron-get-full-path-2">
        <axsl:for-each select="ancestor-or-self::*">
            <axsl:text>/</axsl:text>
            <axsl:value-of select="name(.)"/>
            <axsl:if test="preceding-sibling::*[name(.)=name(current())]">
                <axsl:text>[</axsl:text>
                <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
                <axsl:text>]</axsl:text>
            </axsl:if>
        </axsl:for-each>
        <axsl:if test="not(self::*)">
            <axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if>
    </axsl:template>
    <!--MODE: SCHEMATRON-FULL-PATH-3-->
    <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
    
    <axsl:template match="node() | @*" mode="schematron-get-full-path-3">
        <axsl:for-each select="ancestor-or-self::*">
            <axsl:text>/</axsl:text>
            <axsl:value-of select="name(.)"/>
            <axsl:if test="parent::*">
                <axsl:text>[</axsl:text>
                <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
                <axsl:text>]</axsl:text>
            </axsl:if>
        </axsl:for-each>
        <axsl:if test="not(self::*)">
            <axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if>
    </axsl:template>
    
    <!--MODE: GENERATE-ID-FROM-PATH -->
    
    <axsl:template match="/" mode="generate-id-from-path"/>
    <axsl:template match="text()" mode="generate-id-from-path">
        <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
    </axsl:template>
    <axsl:template match="comment()" mode="generate-id-from-path">
        <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
    </axsl:template>
    <axsl:template match="processing-instruction()" mode="generate-id-from-path">
        <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
    </axsl:template>
    <axsl:template match="@*" mode="generate-id-from-path">
        <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <axsl:value-of select="concat('.@', name())"/>
    </axsl:template>
    <axsl:template match="*" mode="generate-id-from-path" priority="-0.5">
        <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <axsl:text>.</axsl:text>
        <axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
    </axsl:template>
    
    <!--MODE: GENERATE-ID-2 -->
    
    <axsl:template match="/" mode="generate-id-2">U</axsl:template>
    <axsl:template match="*" mode="generate-id-2" priority="2">
        <axsl:text>U</axsl:text>
        <axsl:number level="multiple" count="*"/>
    </axsl:template>
    <axsl:template match="node()" mode="generate-id-2">
        <axsl:text>U.</axsl:text>
        <axsl:number level="multiple" count="*"/>
        <axsl:text>n</axsl:text>
        <axsl:number count="node()"/>
    </axsl:template>
    <axsl:template match="@*" mode="generate-id-2">
        <axsl:text>U.</axsl:text>
        <axsl:number level="multiple" count="*"/>
        <axsl:text>_</axsl:text>
        <axsl:value-of select="string-length(local-name(.))"/>
        <axsl:text>_</axsl:text>
        <axsl:value-of select="translate(name(),':','.')"/>
    </axsl:template>
    <!--Strip characters-->
    <axsl:template match="text()" priority="-1"/>
    
    <!--SCHEMA METADATA-->
    
    <axsl:template match="/">
        <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="Norwegian rules for EHF Order response" schemaVersion="">
            <axsl:comment>
                <axsl:value-of select="$archiveDirParameter"/>
                <axsl:value-of select="$archiveNameParameter"/>
                <axsl:value-of select="$fileNameParameter"/>
                <axsl:value-of select="$fileDirParameter"/>
            </axsl:comment>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" prefix="cbc"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" prefix="cac"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:OrderResponse-2" prefix="ubl"/>
            <svrl:active-pattern>
                <axsl:attribute name="id">EHFProfiles_T76</axsl:attribute>
                <axsl:attribute name="name">EHFProfiles_T76</axsl:attribute>
                <axsl:apply-templates/>
            </svrl:active-pattern>
            <axsl:apply-templates select="/" mode="M7"/>
        </svrl:schematron-output>
    </axsl:template>
    
    <!--SCHEMATRON PATTERNS-->
    
    <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Norwegian rules for EHF Order response</svrl:text>
    
      
    <!--PATTERN EHFProfiles_T76 -->
    
    <!--RULE-->
    <axsl:template match="/ubl:OrderResponse" priority="1007" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderResponse"/>
        
         
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="(cbc:UBLVersionID != '')"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(cbc:UBLVersionID)">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R007]-An order response MUST have a syntax identifier.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <!--ASSERT -->
        <axsl:choose>
            <!--check that node is not empty, or only contains comments-->
            <axsl:when test="not(count(//*[not(node()[not(self::comment())])]) &gt; 0)"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(count(//*[not(node()[not(self::comment())])]) &gt; 0)">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R010]-An order response MUST not contain empty elements.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    <!--RULE -->
    
    <axsl:template match="//*[contains(name(),'Date')]" priority="1000" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*[contains(name(),'Date')]"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="(string(.) castable as xs:date) and (string-length(.) = 10)"/>
            
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string(.) castable as xs:date) and (string-length(.) = 10)">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R001]- A date must be formatted YYYY-MM-DD.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    <!--RULE -->
    <axsl:template match="//cac:Party/cbc:EndpointID" priority="1000" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cbc:EndpointID"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="@schemeID = 'NO:ORGNR'"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@schemeID = 'NO:ORGNR' ">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R002]-An endpoint identifier scheme MUST have the value 'NO:ORGNR'.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
     
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="(string(.) castable as xs:integer) and (string-length(.) = 9)"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string(.) castable as xs:integer) and (string-length(.) = 9)">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R003]- MUST be a norwegian organizational number. Only numerical value allowed</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    <!--RULE-->
    <axsl:template match="//cac:BuyerCustomerParty" priority="1007" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cac:BuyerCustomerParty"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="cac:Party/cbc:EndpointID"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cac:Party/cbc:EndpointI">
                    <axsl:attribute name="flag">warning</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path-3"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R005]- A buyer should have an EndpointID.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    
    <!--RULE-->
    <axsl:template match="//cac:SellerSupplierParty" priority="1007" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cac:BuyerCustomerParty"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="cac:Party/cbc:EndpointID"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cac:Party/cbc:EndpointI">
                    <axsl:attribute name="flag">warning</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path-3"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R006]- A seller should have an EndpointID.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        
        <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    <!--RULE -->
    <axsl:template match="//cac:TaxScheme" priority="1012" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cac:TaxScheme"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="cbc:ID"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R008]-Every tax scheme MUST be defined through an identifier.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
   
    <!--RULE -->
    <axsl:template match="//cac:Delivery" priority="1012" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cac:Delivery"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="cac:PromisedDeliveryPeriod"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cac:PromisedDeliveryPeriod">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R004]-Information on promised delivery period must be filled if element Delivery exists.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    
    <!--RULE -->
    <axsl:template match="//cac:Item/cac:AdditionalItemProperty" priority="1012" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cac:Item/cac:AdditionalItemProperty"/>
        
        <!--ASSERT -->
        <axsl:choose>
            <axsl:when test="(cbc:Value != '')"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(cbc:Value != '')">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path"/>
                    </axsl:attribute>
                    <svrl:text>[NOGOV-T76-R009]-Value must be filled if additional item property is present.</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    
    
    
    <!--RULE -->
    
    <axsl:template match="//cbc:ProfileID" priority="1001" mode="M7">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cbc:ProfileID"/>
        
        <!--ASSERT -->
        
        <axsl:choose>
            <axsl:when test=". = 'urn:www.cenbii.eu:profile:bii28:ver2.0'"/>
            <axsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                    test=". = 'urn:www.cenbii.eu:profile:bii01:ver2.0'">
                    <axsl:attribute name="flag">fatal</axsl:attribute>
                    <axsl:attribute name="location">
                        <axsl:apply-templates select="." mode="schematron-get-full-path-3"/>
                    </axsl:attribute>
                    <svrl:text>[EHFPROFILE-T76-R001]-An order response must only be used in profile 28</svrl:text>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
    <axsl:template match="text()" priority="-1" mode="M7"/>
    <axsl:template match="@*|node()" priority="-2" mode="M7">
        <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
    </axsl:template>
</axsl:stylesheet>