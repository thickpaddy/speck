<cfsetting enablecfoutputonly="Yes">
<!---
This collective work is Copyright (C) 2001-2007 by Robin Hilliard (robin@zeta.org.au) and Mark Woods (mark@thickpaddy.com), 
All Rights Reserved. Individual portions may be copyright by individual contributors, and are included in this collective 
work with permission of the copyright owners.

Licensed under the Academic Free License version 2.1
--->

<cf_spPropertyHandler>

	<cf_spPropertyHandlerMethod method="validateAttributes">

		<cfparam name="stPD.contentType" default="">
		<cfparam name="stPD.displayProperty" default="spLabel">
		<cfparam name="stPD.maxSelect" default="1">
		
		<cfif trim(stPD.contentType) eq "">
		
			<cf_spError error="ATTR_REQ" lParams="contentType" context=#caller.ca.context#>
		
		</cfif>
		
		<cfset stPD.maxSelect = int(val(stPD.maxSelect))>
		<cfif stPD.maxSelect lt 1>
		
			<!--- invalid attribute value - maxSelect must be gt 0 --->
			<cf_spError error="ATTR_INV" lParams="#stPD.maxSelect#,maxSelect" context=#caller.ca.context#>
		
		</cfif>

		<!--- set the maxLength using maxSelect attribute --->	
		<!--- <cfset stPD.maxLength = (stPD.maxSelect * 36) - 1> --->
		
		<!--- set the maxLength of the db column to 2000 so we can deal with changes to the maxSelect attribute --->
		<cfset stPD.maxLength = 2000>
			
	</cf_spPropertyHandlerMethod>
	
	
	<cf_spPropertyHandlerMethod method="renderFormField">
	
		<!--- obtain query containing all content of this type --->
		<cf_spContentGet type="#stPD.contentType#" orderby="#stPD.displayProperty#" r_qContent="qContent">
	
		<cfscript>
			size = int(val(listLast(stPD.displaySize)));
			if ( stPD.maxSelect eq 1 ) {
				size = 1;
			} else {
				if ( size lt 1 or size lt stPD.maxSelect )
					size = stPD.displaySize;
				if ( size gt 10 )
					size = 10;
			}
		</cfscript>
		
		<cfif stPD.maxSelect gt 1>
		
			<cfoutput>
			<script type="text/javascript">
				// Modified versions of selectbox functions by Matt Kruse <matt@mattkruse.com>
				// Check out his JavaScript toolbox at http://www.mattkruse.com/
				function hasOptions_#stPD.name#(obj) {
					if (obj!=null && obj.options!=null) { return true; }
					return false;
				}
				
				function moveSelectedOptions_#stPD.name#(from,to) {
					// Move them over
					if (!hasOptions_#stPD.name#(from)) { return; }
					for (var i=0; i<from.options.length; i++) {
						var o = from.options[i];
						if (o.selected) {
							if (!hasOptions_#stPD.name#(to)) { var index = 0; } else { var index=to.options.length; }
							to.options[index] = new Option( o.text, o.value, false, false);
						}
					}
					// Delete them from original
					for (var i=(from.options.length-1); i>=0; i--) {
						var o = from.options[i];
						if (o.selected) {
							from.options[i] = null;
						}
					}
					if ((arguments.length<3) || (arguments[2]==true)) {
						sortSelect_#stPD.name#(from);
						sortSelect_#stPD.name#(to);
					}
					from.selectedIndex = -1;
					to.selectedIndex = -1;
				}
				
				function sortSelect_#stPD.name#(obj) {
					var o = new Array();
					if (!hasOptions_#stPD.name#(obj)) { return; }
					for (var i=0; i<obj.options.length; i++) {
						o[o.length] = new Option( obj.options[i].text, obj.options[i].value, obj.options[i].defaultSelected, obj.options[i].selected) ;
					}
					if (o.length==0) { return; }
					o = o.sort( 
						function(a,b) { 
							if ((a.text+"") < (b.text+"")) { return -1; }
							if ((a.text+"") > (b.text+"")) { return 1; }
							return 0;
						} 
					);
				
					for (var i=0; i<o.length; i++) {
						obj.options[i] = new Option(o[i].text, o[i].value, o[i].defaultSelected, o[i].selected);
					}
				}
				
				function selectAllOptions_#stPD.name#(obj) {
					if (!hasOptions_#stPD.name#(obj)) { return; }
					for (var i=0; i<obj.options.length; i++) {
						obj.options[i].selected = true;
					}
				}
				
				function checkMaxSelect_#stPD.name#() {
					if ( document.speditform.#stPD.name#.options.length == #stPD.maxSelect# ) {
						alert("#jsStringFormat(request.speck.buildString("P_SIMPLEPICKER_MAX_SELECTED","#stPD.caption#"))#");
						return false;
					} else {
						return true;	
					}
				}
				
				// add selectAllOptions() to form onsubmit
				if ( document.speditform.onsubmit ) 
					otherOnSubmit_#stPD.name# = document.speditform.onsubmit;
				else 
					otherOnSubmit_#stPD.name# = new Function;
				document.speditform.onsubmit = function() {
													selectAllOptions_#stPD.name#(document.speditform.#stPD.name#);
													otherOnSubmit_#stPD.name#();
												};
			</script>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
			<td width="45%">#request.speck.buildString("P_SIMPLEPICKER_AVAILABLE")#<br />
				<select name="#stPD.name#_from" multiple="yes" size="#size#" style="width:100%;">
				</cfoutput>
				
				<cfloop query="qContent">
					
					<cfif not listFind(value,spId)>
					
						<cfoutput><option value="#spId#">#evaluate("#stPD.displayProperty#")#</option></cfoutput>
						
					</cfif>
		
				</cfloop>
						
				<cfoutput>
				</select>
			</td>
			<td width="10%" style="vertical-align:middle;text-align:center;">
				<input name="#stPD.name#_right" value="&gt;&gt;" onclick="if ( checkMaxSelect_#stPD.name#() ) moveSelectedOptions_#stPD.name#(this.form['#stPD.name#_from'],this.form['#stPD.name#'],true);" type="button"><br />
				<input name="#stPD.name#_left" value="&lt;&lt;" onclick="moveSelectedOptions_#stPD.name#(this.form['#stPD.name#'],this.form['#stPD.name#_from'],true)" type="button">
			</td>
			<td width="45%">#request.speck.buildString("P_SIMPLEPICKER_SELECTED")#<br />
				<select name="#stPD.name#" multiple="yes" size="#size#" style="width:100%;">
				</cfoutput>
				
				<cfloop query="qContent">
					
					<cfif listFind(value,spId)>
					
						<cfoutput><option value="#spId#">#evaluate("#stPD.displayProperty#")#</option></cfoutput>
						
					</cfif>
		
				</cfloop>
						
				<cfoutput>
				</select>
			</td>
			</tr>
			</table>
			(#request.speck.buildString("P_SIMPLEPICKER_MAXSELECT_NOTE","#stPD.maxSelect#,#stPD.caption#")#)
			</cfoutput>
		
		<cfelse>
		
			<cfoutput>
			<select name="#stPD.name#" size="#size#">
			</cfoutput>
		
			<cfset forceWidth = "">
			<cfif listLen(stPD.displaySize) eq 2>
			
				<cfscript>
					width = int(val(listFirst(stPD.displaySize)));
					forceWidth = "";
					for (i=1; i lte width; i = i+1)
						forceWidth = forceWidth & "&nbsp;";
				</cfscript>
			
			</cfif>
			
			<!--- throw in an empty option/value --->
			<cfoutput><option value="">#forceWidth#</option></cfoutput>
			
			<cfloop query="qContent">
			
				<cfoutput><option value="#spId#"<cfif listFind(value,spId)> selected="yes"</cfif>>#evaluate("#stPD.displayProperty#")#</option></cfoutput>
			
			</cfloop>
			
			<cfoutput>
			</select>
			</cfoutput>
				
		</cfif>
	
	</cf_spPropertyHandlerMethod>

	
	<cf_spPropertyHandlerMethod method="validateValue">
	
		<cfif listLen(newValue) gt stPD.maxSelect>
			<cfset lErrors = request.speck.buildString("P_SIMPLEPICKER_SELECTED_GT_MAXSELECT", "#stPD.caption#,#listLen(newValue)#,#stPD.maxSelect#")>
		</cfif>
		
		<cfloop list="#newValue#" index="id">
			<cfif not request.speck.isUUID(id)>
				<cfset lErrors = listAppend(lErrors, request.speck.buildString("P_PICKER_NOT_UUID", id))>
			</cfif>
		</cfloop>
		
	</cf_spPropertyHandlerMethod>
	
	
</cf_spPropertyHandler>