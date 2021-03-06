<cfsetting enablecfoutputonly="Yes">

<cfparam name="form.spLogonUser" default="">
<cfparam name="form.spLogonPassword" default="">

<cfparam name="attributes.fieldset" default="true" type="boolean">
<cfparam name="attributes.legend" default="Please log in to continue">

<cfscript>
	queryString = cgi.query_string;
	for ( key in url ) {
		if ( not findNoCase(key & "=",cgi.query_string)) {
			queryString = listAppend(queryString,lCase(key) & "=" & urlEncodedFormat(url[key]),"&");
		}
	}
	if ( not structKeyExists(form,"referrer") ) {
		if ( len(cgi.HTTP_REFERER) ) {
			form.referrer = cgi.HTTP_REFERER;
		} else {
			form.referrer = "";
		}
	}
</cfscript>

<cfoutput>
<script type="text/javascript">
	<!--
	//<![CDATA[
	if ( window.onload ) 
		otherOnLoad = window.onload;
	else 
		otherOnLoad = new Function;
	window.onload = function() { otherOnLoad(); document.spLogonForm.spLogonUser.focus() };
	//]]>
	//-->
</script>
<form id="spLogonForm" name="spLogonForm" action="#cgi.script_name#?#queryString#" method="post">
<input type="hidden" name="referer" value="#form.referrer#" />
</cfoutput>

<cfif attributes.fieldset>

	<cfoutput>
	<fieldset><legend>#attributes.legend#</legend>
	</cfoutput>
	
<cfelseif len(attributes.legend)>

	<cfoutput>
	<p style="padding-left:3px;margin:10px 0 0 0;">#attributes.legend#</p>
	</cfoutput>
	
</cfif>
	
<cfif isDefined("request.speck.failedLogon")>
	
	<cfoutput>
	<p class="logon_form_error" style="color:red;padding-left:3px;margin:10px 0 0 0;">
	<cfif structKeyExists(request.speck,"failedLogonMessage")>
		Login failed, #lCase(request.speck.failedLogonMessage)#
	<cfelse>
		Login failed, please try again.
	</cfif>
	</p>
	</cfoutput>
	
</cfif>

<cfoutput>
<table style="padding:3px;margin:10px 0;" width="280">
	<tr>
	<td style="vertical-align:middle;padding:3px;"><label for="spLogonUser">Username</label></td>
	<td style="padding-right:0;" align="right"><input type="text" style="width:180px;" class="form_field" name="spLogonUser" id="spLogonUser" value="#form.spLogonUser#" size="25" maxlength="100" /></td>
	</tr>
	<tr>
	<td style="vertical-align:middle;padding:3px;"><label for="spLogonPassword">Password</label></td>
	<td style="padding-right:0;" align="right"><input type="password" style="width:180px;" class="form_field" name="spLogonPassword" id="spLogonPassword" value="#form.spLogonPassword#" size="25" maxlength="100" /></td>
	</tr>
	<tr>
	<td colspan="2" align="right" style="padding-right:0;">
	<input type="submit" class="form_button" value="Login" />
	<cfif len(form.referrer)>
		<input type="button" class="form_button" onclick="window.location.href='#form.referrer#';" value="Cancel">
	</cfif>
	</td>
	</tr>
</cfoutput>

<cfquery name="qRegisterKeyword" dbtype="query">
	SELECT * FROM request.speck.qKeywords WHERE template = 'register'
</cfquery>

<cfsavecontent variable="notRegisteredHtml">

	<cfif qRegisterKeyword.recordCount>
	
		<cfoutput>
		<a href="#cgi.script_name#?spKey=#qRegisterKeyword.keyword#&redirect_to=#urlEncodedFormat(cgi.script_name & "?" & queryString)#">Not Registered?</a>
		</cfoutput>
		
	</cfif>

</cfsavecontent>

<cfsavecontent variable="forgotPasswordHtml">

	<!--- if forogt password template is found, link to it --->
	<cfquery name="qForgotPasswordKeyword" dbtype="query">
		SELECT * FROM request.speck.qKeywords WHERE template = 'forgot_password'
	</cfquery>
	
	<cfif qForgotPasswordKeyword.recordCount>
	
		<cfoutput>
		<a href="#cgi.script_name#?spKey=#qForgotPasswordKeyword.keyword#&redirect_to=#urlEncodedFormat(cgi.script_name & "?" & queryString)#">Forgot Password?</a>
		</cfoutput>
	
	</cfif>

</cfsavecontent>

<cfif len(notRegisteredHtml) or len(forgotPasswordHtml)>
	
	<cfoutput>
	<tr><td colspan="2" align="center"><div style="padding:0;margin:10px 0 0 0;">
	</cfoutput>
	
	<cfif len(notRegisteredHtml)>
	
		<cfoutput>#notRegisteredHtml#</cfoutput>
		
	</cfif>
	
	<cfif len(forgotPasswordHtml)>
	
		<cfif len(notRegisteredHtml)>
		
			<cfoutput> | </cfoutput>
		
		</cfif>
	
		<cfoutput>#forgotPasswordHtml#</cfoutput>
	
	</cfif>

	<cfoutput></div></td></tr></cfoutput>

</cfif>

<cfoutput>
</table>
<cfif attributes.fieldset>
	</fieldset>
</cfif>
</form>
</cfoutput>

