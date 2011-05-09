<?xml version="1.0" encoding="utf-8"?>
<!--====================================================================
$Id$
Copyright 2009 Aplix Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

XSLT stylesheet to convert widlprocxml into html documentation.
=====================================================================-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="html"/>

<xsl:param name="date" select="'error: missing date'"/>
<xsl:param name="requiredescriptive" select="1"/>

<xsl:variable name="title" select="concat('The Bondi ',/Definitions/*[1]/@name,' Module - Version ',/Definitions/Module/descriptive/version)"/>

<!-- section number of the Interfaces section. If there are typedefs, this is 3, otherwise 2 -->
<xsl:variable name="interfaces-section-number">
  <xsl:choose>
    <xsl:when test="/Definitions/Module/Typedef">3</xsl:when>
    <xsl:otherwise>2</xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<!--Root of document.-->
<xsl:template match="/">
    <html>
        <head>
            <link rel="stylesheet" type="text/css" href="widlhtml.css" media="screen"/>
            <title>
                <xsl:value-of select="$title"/>
            </title>
        </head>
        <body>
            <xsl:apply-templates/>
        </body>
    </html>
</xsl:template>

<!--Module: a whole API.-->
<xsl:template match="Module">
    <div class="api" id="{@id}">
        <a href="http://bondi.omtp.org"><img src="http://www.omtp.org/images/BondiSmall.jpg" alt="Bondi logo"/></a>
        <h1><xsl:value-of select="$title"/></h1>
        <h3>12 May 2009</h3>

        <h2>Authors</h2>
        <ul class="authors">
          <xsl:apply-templates select="descriptive/author"/>
        </ul>

        <p class="copyright"><small>© 2009 OMTP Ltd. All rights reserved. OMTP and OMTP BONDI are registered trademarks of OMTP Ltd.</small></p>

        <hr/>

        <h2>Abstract</h2>

        <xsl:apply-templates select="descriptive/brief"/>

        <h2>Table of Contents</h2>
        <ul class="toc">
          <li>1. <a href="#intro">Introduction</a>
          <ul>
            <xsl:if test="descriptive/def-api-feature-set">
              <li>1.1. <a href="#def-api-feature-sets">Feature set</a></li>
            </xsl:if>
            <xsl:if test="descriptive/def-api-feature">
              <li>1.2. <a href="#def-api-features">Features</a></li>
            </xsl:if>
            <xsl:if test="descriptive/def-device-cap">
              <li>1.3. <a href="#def-device-caps">Device Capabilities</a></li>
            </xsl:if>
          </ul>
          </li>
          <xsl:if test="Typedef">
            <li>2. <a href="#typedefs">Type Definitions</a>
            <ul class="toc">
              <xsl:for-each select="Typedef[descriptive or not($requiredescriptive)]">
                <li>2.<xsl:number value="position()"/>. <a href="#{@id}"><code><xsl:value-of select="@name"/></code></a></li>
              </xsl:for-each>
            </ul>
            </li>
          </xsl:if>
          <li><xsl:number value="$interfaces-section-number"/>. <a href="#interfaces">Interfaces</a>
          <ul class="toc">
          <xsl:for-each select="Interface[descriptive or not($requiredescriptive)]">
            <li><xsl:number value="$interfaces-section-number"/>.<xsl:number value="position()"/>. <a href="#{@id}"><code><xsl:value-of select="@name"/></code></a></li>
          </xsl:for-each>
          </ul>
          </li>
        </ul>

        <hr/>

        <h2>Summary of Methods</h2>
        <xsl:call-template name="summary"/>
        
        <h2 id="intro">1. Introduction</h2>
        <xsl:apply-templates select="descriptive/description"/>

        <xsl:apply-templates select="descriptive/Code"/>

        <xsl:if test="descriptive/def-api-feature-set">
            <div id="def-api-feature-sets" class="def-api-feature-sets">
                <h3 id="features">1.1. Feature set</h3>
                <p>This is the URI used to declare this API's feature set, for use in bondi.requestFeature. For the URL, the list of features included by the feature set is provided.</p>
                <xsl:apply-templates select="descriptive/def-api-feature-set"/>
            </div>
        </xsl:if>
        <xsl:if test="descriptive/def-api-feature">
            <div id="def-api-features" class="def-api-features">
                <h3 id="features">1.2. Features</h3>
                <p>This is the list of URIs used to declare this API's features, for use in bondi.requestFeature. For each URL, the list of functions covered is provided.</p>
                <xsl:apply-templates select="Interface/descriptive/def-instantiated"/>
                <xsl:apply-templates select="descriptive/def-api-feature"/>
            </div>
        </xsl:if>
        <xsl:if test="descriptive/def-device-cap">
            <div class="def-device-caps" id="def-device-caps">
                <h3>1.3. Device capabilities</h3>
                <dl>
                  <xsl:apply-templates select="descriptive/def-device-cap"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:if test="Typedef">
            <div class="typedefs" id="typedefs">
                <h2>2. Type Definitions</h2>
                <xsl:apply-templates select="Typedef[descriptive or not($requiredescriptive)]"/>
            </div>
        </xsl:if>
        <h2><xsl:value-of select="$interfaces-section-number"/>. Interfaces</h2>
        <xsl:apply-templates select="Interface"/>
    </div>
</xsl:template>

<!--def-api-feature-set-->
<xsl:template match="def-api-feature-set">
      <dl class="def-api-feature-set">
          <dt><xsl:value-of select="@identifier"/></dt>
          <dd>
            <xsl:apply-templates select="descriptive/brief"/>
            <xsl:apply-templates select="descriptive"/>
            <xsl:apply-templates select="descriptive/Code"/>
            <xsl:if test="descriptive/api-feature">
              <div class="api-features">
                <p>
                  Includes API features:
                </p>
                <ul>
                  <xsl:for-each select="descriptive/api-feature">
                    <li><code><xsl:value-of select="@identifier"/></code></li>
                  </xsl:for-each>
                </ul>
              </div>
            </xsl:if>
          </dd>
      </dl>
</xsl:template>

<!--def-api-feature-->
<xsl:template match="def-api-feature">
      <dl class="def-api-feature">
          <dt><xsl:value-of select="@identifier"/></dt>
          <dd>
            <xsl:apply-templates select="descriptive/brief"/>
            <xsl:apply-templates select="descriptive"/>
            <xsl:apply-templates select="descriptive/Code"/>
            <xsl:if test="descriptive/device-cap">
              <div class="device-caps">
                <p>
                  Device capabilities:
                </p>
                <ul>
                  <xsl:for-each select="descriptive/device-cap">
                    <li><code><xsl:value-of select="@identifier"/></code></li>
                  </xsl:for-each>
                </ul>
              </div>
            </xsl:if>
          </dd>
      </dl>
</xsl:template>

<!--def-device-cap-->
<xsl:template match="def-device-cap">
    <dt class="def-device-cap"><code><xsl:value-of select="@identifier"/></code></dt>
    <dd>
      <xsl:apply-templates select="descriptive/brief"/>
      <xsl:apply-templates select="descriptive"/>
      <xsl:apply-templates select="descriptive/Code"/>
      <xsl:if test="descriptive/param">
        <div class="device-caps">
          <p>Security parameters:</p>
          <ul>
            <xsl:apply-templates select="descriptive/param"/>
          </ul>
        </div>
      </xsl:if>
    </dd>
</xsl:template>

<!--Exception: not implemented-->
<!--Valuetype: not implemented-->
<xsl:template match="Exception|Valuetype|Const">
    <xsl:if test="descriptive">
        <xsl:message terminate="yes">element <xsl:value-of select="name()"/> not supported</xsl:message>
    </xsl:if>
</xsl:template>

<!--Typedef.-->
<xsl:template match="Typedef">
  <xsl:if test="descriptive  or not($requiredescriptive)">
    <div class="typedef" id="{@id}">
        <h3>2.<xsl:number value="position()"/>. <code><xsl:value-of select="@name"/></code></h3>
        <xsl:apply-templates select="descriptive/brief"/>
        <xsl:apply-templates select="webidl"/>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="descriptive/Code"/>
    </div>
  </xsl:if>
</xsl:template>

<!--Interface.-->
<xsl:template match="Interface">
  <xsl:if test="descriptive  or not($requiredescriptive)">
    <xsl:variable name="name" select="@name"/>
    <div class="interface" id="{@id}">
        <h3><xsl:value-of select="concat($interfaces-section-number,'.',1+count(preceding::Interface))"/>. <code><xsl:value-of select="@name"/></code></h3>
        <xsl:apply-templates select="descriptive/brief"/>
        <xsl:apply-templates select="webidl"/>
        <xsl:apply-templates select="../Implements[@name2=$name]/webidl"/>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="descriptive/Code"/>
        <xsl:apply-templates select="InterfaceInheritance"/>
        <xsl:if test="Const[descriptive or not($requiredescriptive)]">
            <div class="consts">
                <h4>Constants</h4>
                <dl>
                  <xsl:apply-templates select="Const[descriptive or not($requiredescriptive)]"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:if test="Attribute[descriptive or not($requiredescriptive)]">
            <div class="attributes">
                <h4>Attributes</h4>
                <dl>
                  <xsl:apply-templates select="Attribute[descriptive or not($requiredescriptive)]"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:if test="Operation[descriptive or not($requiredescriptive)]">
            <div class="methods">
                <h4>Methods</h4>
                <dl>
                  <xsl:apply-templates select="Operation"/>
                </dl>
            </div>
        </xsl:if>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template match="InterfaceInheritance/ScopedNameList">
              <p>
                <xsl:text>This interface inherits from: </xsl:text>
                <xsl:for-each select="Name">
                  <code><xsl:value-of select="@name"/></code>
                  <xsl:if test="position!=last()">, </xsl:if>
                </xsl:for-each>
              </p>
</xsl:template>

<!--Attribute-->
<xsl:template match="Attribute">
    <dt class="attribute" id="{@name}">
        <code>
            <xsl:if test="@stringifier">
                stringifier
            </xsl:if>
            <xsl:if test="@readonly">
                readonly
            </xsl:if>
            <xsl:apply-templates select="Type"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
        </code></dt>
        <dd>
          <xsl:apply-templates select="descriptive/brief"/>
          <xsl:apply-templates select="descriptive"/>
          <xsl:apply-templates select="GetRaises"/>
          <xsl:apply-templates select="SetRaises"/>
          <xsl:apply-templates select="descriptive/Code"/>
        </dd>
</xsl:template>

<!--Const-->
<xsl:template match="Const">
  <dt class="const" id="{@id}">
    <code>
      <xsl:apply-templates select="Type"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@name"/>
    </code>
  </dt>
  <dd>
    <xsl:apply-templates select="descriptive/brief"/>
    <xsl:apply-templates select="descriptive"/>
    <xsl:apply-templates select="descriptive/Code"/>
  </dd>
</xsl:template>

<!--Operation-->
<xsl:template match="Operation">
    <dt class="method" id="{concat(@name,generate-id(.))}">
        <code><xsl:value-of select="@name"/></code>
    </dt>
    <dd>
        <xsl:apply-templates select="descriptive/brief"/>
        <div class="synopsis">
            <h6>Signature</h6>
            <pre>
	      <xsl:if test="@static">
                    <xsl:value-of select="concat(@static, ' ')"/>
	      </xsl:if>
                <xsl:if test="@stringifier">
                    <xsl:value-of select="concat(@stringifier, ' ')"/>
                </xsl:if>
                <xsl:if test="@omittable">
                    <xsl:value-of select="concat(@omittable, ' ')"/>
                </xsl:if>
                <xsl:if test="@getter">
                    <xsl:value-of select="concat(@getter, ' ')"/>
                </xsl:if>
                <xsl:if test="@setter">
                    <xsl:value-of select="concat(@setter, ' ')"/>
                </xsl:if>
                <xsl:if test="@creator">
                    <xsl:value-of select="concat(@creator, ' ')"/>
                </xsl:if>
                <xsl:if test="@deleter">
                    <xsl:value-of select="concat(@deleter, ' ')"/>
                </xsl:if>
                <xsl:if test="@caller">
                    <xsl:value-of select="concat(@caller, ' ')"/>
                </xsl:if>
                <xsl:apply-templates select="Type"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="ArgumentList">
                    <xsl:with-param name="nodesc" select="1"/>
                </xsl:apply-templates>
                <xsl:text>);
</xsl:text></pre>
        </div>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="ArgumentList"/>
        <xsl:if test="Type[descriptive or not($requiredescriptive)]">
          <div class="returntype">
            <h5>Return value</h5>
            <xsl:apply-templates select="Type[descriptive or not($requiredescriptive)]"/>
          </div>
        </xsl:if>
        <xsl:apply-templates select="Raises"/>
        <xsl:if test="descriptive/api-feature">
            <div class="api-features">
                <h6>API features</h6>
                <dl>
                    <xsl:apply-templates select="descriptive/api-feature"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:apply-templates select="descriptive/Code"/>
    </dd>
</xsl:template>

<!--ArgumentList. This is passed $nodesc=true to output just the argument
    types and names, and not any documentation for them.-->
<xsl:template match="ArgumentList">
    <xsl:param name="nodesc"/>
    <xsl:choose>
        <xsl:when test="$nodesc">
            <!--$nodesc is true: just output the types and names-->
            <xsl:apply-templates select="Argument[1]">
                <xsl:with-param name="nodesc" select="'nocomma'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="Argument[position() != 1]">
                <xsl:with-param name="nodesc" select="'comma'"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="Argument">
            <!--$nodesc is false: output the documentation-->
            <div class="parameters">
                <h6>Parameters</h6>
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </div>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!--Argument. This is passed $nodesc=false to output the documentation,
    or $nodesc="nocomma" to output the type and name, or $nodesc="comma"
    to output a comma then the type and name. -->
<xsl:template match="Argument">
    <xsl:param name="nodesc"/>
    <xsl:choose>
        <xsl:when test="$nodesc">
            <!--$nodesc is true: just output the types and names-->
            <xsl:if test="$nodesc = 'comma'">
                <!--Need a comma first.-->
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:if test="@in"><xsl:value-of select="concat(@in, ' ')"/></xsl:if>
            <xsl:if test="@optional"><xsl:value-of select="concat(@optional, ' ')"/></xsl:if>
            <xsl:apply-templates select="Type"/>
            <xsl:if test="@ellipsis"><xsl:text>...</xsl:text></xsl:if>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
            <!--$nodesc is false: output the documentation-->
            <li class="param">
                <xsl:value-of select="@name"/>:
                <xsl:apply-templates select="descriptive"/>
            </li>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--Raises (for an Operation). It is already known that the list
    is not empty.-->
<xsl:template match="Raises">
    <div class="exceptionlist">
        <h5>Exceptions</h5>
        <ul>
            <xsl:apply-templates/>
        </ul>
    </div>
</xsl:template>

<!--RaiseException, the name of an exception in a Raises.-->
<xsl:template match="RaiseException">
    <li class="exception">
        <xsl:value-of select="@name"/>:
        <xsl:apply-templates select="descriptive"/>
    </li>
</xsl:template>

<!--Type.-->
<xsl:template match="Type">
    <xsl:choose>
        <xsl:when test="Type">
	  <xsl:choose>
	    <xsl:when test="@type='sequence'">
	      <xsl:text>sequence &lt;</xsl:text>
	      <xsl:apply-templates/>
	      <xsl:text>></xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:apply-templates/>
	      <xsl:text>[]</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:if test="@nullable">
	    <xsl:text>?</xsl:text>
	  </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@name"/>
            <xsl:value-of select="@type"/>
            <xsl:if test="@nullable">
                <xsl:text>?</xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="descriptive[not(author)]">
  <xsl:apply-templates select="version"/>
  <xsl:if test="author">
  </xsl:if>
  <xsl:apply-templates select="description"/>
</xsl:template>

<!--brief-->
<xsl:template match="brief">
    <div class="brief">
        <p>
            <xsl:apply-templates/>
        </p>
    </div>
</xsl:template>

<!--description in ReturnType or Argument or ScopedName-->
<xsl:template match="Type/descriptive/description|Argument/descriptive/description|Name/descriptive/description">
    <!--If the description contains just a single <p> then we omit
        the <p> and just do its contents.-->
    <xsl:choose>
        <xsl:when test="p and count(*) = 1">
            <xsl:apply-templates select="p/*|p/text()"/>
        </xsl:when>
        <xsl:otherwise>
            <div class="description">
                <xsl:apply-templates/>
            </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--Other description-->
<xsl:template match="description">
    <div class="description">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<!--Code-->
<xsl:template match="Code">
    <div class="example">
        <h5>Code example</h5>
        <pre class="examplecode"><xsl:apply-templates/></pre>
    </div>
</xsl:template>

<!--webidl : literal Web IDL from input-->
<xsl:template match="webidl">
    <pre class="webidl"><xsl:apply-templates/></pre>
</xsl:template>

<!--author-->
<xsl:template match="author">
    <li class="author"><xsl:apply-templates/></li>
</xsl:template>

<!--version-->
<xsl:template match="version">
    <div class="version">
        <h2>
            Version: <xsl:apply-templates/>
        </h2>
    </div>
</xsl:template>

<!--api-feature-->
<xsl:template match="api-feature">
    <dt>
        <xsl:value-of select="@identifier"/>
    </dt>
    <dd>
        <xsl:apply-templates/>
    </dd>
</xsl:template>

<!--param-->
<xsl:template match="param">
    <li>
        <code><xsl:value-of select="@identifier"/></code>:
        <xsl:apply-templates/>
    </li>
</xsl:template>

<!--def-instantiated (called from Module).
    This assumes that only one interface in the module has a def-instantiated,
    and that interface contains just one attribute.-->
<xsl:template match="def-instantiated">
    <xsl:variable name="ifacename" select="../../@name"/>
    <p>
        <xsl:choose>
            <xsl:when test="count(descriptive/api-feature)=1">
                When the feature
            </xsl:when>
            <xsl:otherwise>
                When any of the features
            </xsl:otherwise>
        </xsl:choose>
    </p>
    <ul>
        <xsl:for-each select="descriptive/api-feature">
            <li><code>
                <xsl:value-of select="@identifier"/>
            </code></li>
        </xsl:for-each>
    </ul>
    <p>
        is successfully requested, the interface
        <code><xsl:apply-templates select="../../Attribute/Type"/></code>
        is instantiated, and the resulting object appears in the global
        namespace as
        <code><xsl:value-of select="../../../Implements[@name2=$ifacename]/@name1"/>.<xsl:value-of select="../../Attribute/@name"/></code>.
    </p>
</xsl:template>



<!--html elements-->
<xsl:template match="a|b|br|dd|dl|dt|em|li|p|table|td|th|tr|ul">
    <xsl:element name="{name()}"><xsl:for-each select="@*"><xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute></xsl:for-each><xsl:apply-templates/></xsl:element>
</xsl:template>

<xsl:template name="summary">
  <table class="summary">
    <thead>
      <tr><th>Interface</th><th>Method</th></tr>
    </thead>
    <tbody>
      <xsl:for-each select="Interface[descriptive or not($requiredescriptive)]">
        <tr><td><a href="#{@id}"><xsl:value-of select="@name"/></a></td>
        <td>
          <xsl:for-each select="Operation">

            <xsl:apply-templates select="Type"/>
            <xsl:text> </xsl:text>
            <a href="#{concat(@name,generate-id(.))}"><xsl:value-of select="@name"/></a>
            <xsl:text>(</xsl:text>
            <xsl:for-each select="ArgumentList/Argument">
              <xsl:variable name="type"><xsl:apply-templates select="Type"/></xsl:variable>
              <xsl:value-of select="concat(normalize-space($type),' ',@name)"/>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
            <xsl:if test="position()!=last()"><br/></xsl:if>
          </xsl:for-each>
        </td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
</xsl:template>

<!--<ref> element in literal Web IDL.-->
<xsl:template match="ref[@ref]">
    <a href="{@ref}">
        <xsl:apply-templates/>
    </a>
</xsl:template>

</xsl:stylesheet>

