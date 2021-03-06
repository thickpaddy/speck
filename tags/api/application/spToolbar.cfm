<cfsetting enablecfoutputonly="yes">
<!---
This collective work is Copyright (C) 2001-2007 by Robin Hilliard (robin@zeta.org.au) and Mark Woods (mark@thickpaddy.com), 
All Rights Reserved. Individual portions may be copyright by individual contributors, and are included in this collective 
work with permission of the copyright owners.

Licensed under the Academic Free License version 2.1
--->

<!---
Renders toolbar allowing editors and reviewers (i.e. spEdit or spReview permission) to control:
- The promotion level they are viewing (if promotion enabled)
- The date at which they are viewing the content (if revisions enabled)
- The changes they are working on, and which change to allocate new edits to (if change control enabled)
- Whether or not to display admin links (add, edit, promote, review etc)
 --->

<cfparam name="request.speck.manageKeywords" default="no" type="boolean">
<cfparam name="attributes.manageKeywords" default="#request.speck.manageKeywords#" type="boolean"> <!--- show the manage keywords link? --->

<!--- deprecated config settings and attribtues, do not use --->
<cfparam name="request.speck.toolbarPrefix" default="">
<cfparam name="request.speck.toolbarSuffix" default="">
<cfparam name="attributes.menuPrefix" default="#request.speck.toolbarPrefix#">
<cfparam name="attributes.menuSuffix" default="#request.speck.toolbarSuffix#">
<!--- end of deprecated config settings and attributes --->

<cfparam name="request.speck.toolbarLogo" default="#attributes.menuPrefix#">
<cfparam name="request.speck.toolbarInsert" default="#attributes.menuSuffix#">

<!--- <cfif request.speck.userHasPermission("spSuper,spEdit,spLive")> --->
<cfif structKeyExists(request.speck.session, "roles") and not structIsEmpty(request.speck.session.roles)>
	
	<cfif request.speck.session.auth neq "logon">
	
		<cfif isDefined("request.speck.portal") and ( structKeyExists(request.speck.session,"roles") and not structIsEmpty(request.speck.session.roles) )>
			
			<cfparam name="request.speck.portal.toolbarLogin" default="auto"> <!--- yes|no|auto probable TODO: make this a standard Speck config setting --->
	
			<!--- experimental idea to show login link if auth level is cookie --->
			<!--- TODO: move styles to toolbar.css and get link caption from strings file --->
			<cfoutput>
			<style type="text/css">
			##spToolbarLogin {
				position:absolute;
				z-index:876892234;
				top: 5px;
				right: 5px;
				color: ##aaa; 
				background: transparent; 
				font: 10px Verdana, Arial, Helvetica, sans-serif; 
			}
			##spToolbarLogin a { color: silver; font-weight: normal; background:transparent; text-decoration:none; }
			##spToolbarLogin a:focus,
			##spToolbarLogin a:hover,
			##spToolbarLogin a:active { color: dimgray; text-decoration:underline; background-color: transparent;}
			</style>
			</cfoutput>
			
			<cfif not isBoolean(request.speck.portal.toolbarLogin)>
				
				<!--- assume non-boolean value is "auto" and only show login link if browser width > 1024 --->
				<cfoutput>
				<script type="text/javascript">
					// simple function taken from about.com, but modified to always return an integer (-1 for unknown)
					function pageWidth() {return window.innerWidth != null? window.innerWidth : document.documentElement && document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body != null ? document.body.clientWidth : -1;} 
					if ( pageWidth() > 1024 ) {
						document.write("<div id='spToolbarLogin'>");
					} else {
						document.write("<div id='spToolbarLogin' style='display:none;'>");
					}
					document.write("<a href='/speck/login.cfm?app=#request.speck.appName#'>Administrator Login</a>");
					document.write("</div>");
				</script>
				</cfoutput>
			
			<cfelseif request.speck.portal.toolbarLogin>
			
				<cfoutput>
				<div id="spToolbarLogin">
				<a href="/speck/login.cfm?app=#request.speck.appName#">Administrator Login</a>
				</div>
				</cfoutput>
			
			</cfif>
		
		</cfif>
	
	<cfelse>
		
		<!--- add toolbar stylesheet --->
		<cfoutput>
		<style type="text/css">@import "#request.speck.toolbarStylesheet#";</style>
		</cfoutput>
	
		<cfscript>
			// localised strings...
			stStrings = structNew();
			stStrings.viewLevel = request.speck.buildString("A_TOOLBAR_VIEW_LEVEL");
			stStrings.viewDate = request.speck.buildString("A_TOOLBAR_VIEW_DATE");
			stStrings.showAdminLinks = request.speck.buildString("A_TOOLBAR_SHOW_ADMIN_LINKS");
			stStrings.hideAdminLinks = request.speck.buildString("A_TOOLBAR_HIDE_ADMIN_LINKS");
			stStrings.showCacheInfo = request.speck.buildString("A_TOOLBAR_SHOW_CACHE_INFO");		
			stStrings.hideCacheInfo = request.speck.buildString("A_TOOLBAR_HIDE_CACHE_INFO");
			stStrings.resetCache = request.speck.buildString("A_TOOLBAR_RESET_CACHE");
			stStrings.resetCacheTooltip = request.speck.buildString("A_TOOLBAR_RESET_CACHE_TOOLTIP");
			stStrings.manageKeywords = request.speck.buildString("A_TOOLBAR_MANAGE_KEYWORDS");
			stStrings.manageKeywordsTooltip = request.speck.buildString("A_TOOLBAR_MANAGE_KEYWORDS_TOOLTIP");
			stStrings.logoutCaption = request.speck.buildString("A_TOOLBAR_LOGOUT_CAPTION");
			stStrings.nowCaption = request.speck.buildString("A_TOOLBAR_NOW_CAPTION");
		</cfscript>
		
		<cfoutput>
		<script type="text/javascript">
			<!--
			//<![CDATA[			
			function spToggleAdminLinks() {
				spSendRequest("/speck/admin/session/toggle_admin_links.cfm?app=#request.speck.appName#");
			}
			
			function spToggleCacheInfo() {
				spSendRequest("/speck/admin/session/toggle_cache_info.cfm?app=#request.speck.appName#");
			}
			
			function spLogout() {
				spSendRequest("/speck/admin/session/logout.cfm?app=#request.speck.appName#");
			}
			
			function spSetViewDate() {
				var viewDate = document.spToolbar.spViewDate.value;
				if ( window.ActiveXObject ) {
					spSendRequest("/speck/admin/session/set_view_date.cfm?app=#request.speck.appName#&viewDate=" + escape(viewDate));
				} else {
					// firefox doesn't like it when spSendRequest() is called as a result of a callback from a popup window
					document.getElementById("spLoading").style.visibility = "visible";
					document.spToolbar.style.cursor = "wait";
					document.forms["spToolbar"].submit();
				}
			}
			
			function spSetViewLevel(viewLevel) {
				//var viewLevel = document.spToolbar.spViewLevel.options[document.spToolbar.spViewLevel.selectedIndex].value;
				spSendRequest("/speck/admin/session/set_view_level.cfm?app=#request.speck.appName#&viewLevel=" + escape(viewLevel));
			}
			//]]>
			//-->
		</script>
		<span class="spToolbar" id="spLoading" style="position:absolute;z-index:87655234;top:2px;left:2px;visibility:hidden;vertical-align:middle;">Loading...</span>
		<table class="spToolbar" width="100%">
		<tr class="spToolbar">
		</cfoutput>
		
		<!--- output menu prefix (used to customise toolbar) --->
		<cfif len(request.speck.toolbarLogo)>
	
			<cfoutput><td class="spToolbar spToolbarLogo">#request.speck.toolbarLogo#</td></cfoutput>
		
		</cfif>
		<cfoutput>
		<td class="spToolbar">
		<form class="spToolbar" name="spToolbar" id="spToolbar" method="post" style="margin:0;padding:0;" onsubmit="spSetViewDate();">
		</cfoutput>
	
		<cfif request.speck.enablePromotion>
	
			<!--- Render level dropdown --->
			<cfset lLevels = "Edit,Review,Live">
			
			<cfoutput>
			<span class="spToolbar spViewLevel">
			#stStrings.viewLevel# 
			</cfoutput>
			
			<cfloop list=#lLevels# index="level">
			
				<cfset levelCaption = request.speck.buildString("A_PROMOLEVEL_" & Ucase(level))>
				<cfif find("A_PROMOLEVEL_" & Ucase(level),levelCaption)>
					<cfset levelCaption = level>
				</cfif>
				
				<cfif level eq request.speck.session.viewLevel>
					
					<cfoutput>
					<strong>#levelCaption#</strong>
					</cfoutput>
				
				<cfelse>
				
					<cfoutput>
					<a href="javascript:return false;" onclick="spSetViewLevel('#lCase(level)#');return false;">#levelCaption#</a>
					</cfoutput>
					
				</cfif>
			
				<!--- <cfoutput>
				<input type="radio" name="spViewLevel" onchange="spSetViewLevel();" class="spToolbar" value="#lCase(level)#" <cfif level eq request.speck.session.viewLevel>checked="checked"</cfif>>
				#levelCaption#
				</cfoutput> --->
			
			</cfloop>
			
			<cfoutput>
			</span>
			</cfoutput>
			
			<!--- <cfoutput>
			<span class="spToolbar spViewLevel">
			#stStrings.viewLevel# <select class="spToolbar" name="spViewLevel" onchange="spSetViewLevel();"></cfoutput>
			
			<cfloop list=#lLevels# index="level">
			
				<cfset levelCaption = request.speck.buildString("A_PROMOLEVEL_" & Ucase(level))>
				<cfif find("A_PROMOLEVEL_" & Ucase(level),levelCaption)>
					<cfset levelCaption = level>
				</cfif>
			
				<cfoutput><option class="spToolbar" value="#lCase(level)#" <cfif level eq request.speck.session.viewLevel>selected</cfif>>#levelCaption#</option></cfoutput>
			
			</cfloop>
			
			<cfoutput>
			</select>
			</span>
			</cfoutput> --->
			
		</cfif>
		
		<cfif request.speck.enableRevisions>
		
			<!--- Process view date field if form posted --->
			<cfif isDefined("form.spViewDate")>
			
				<cflock scope="session" type="exclusive" timeout="3" throwontimeout="Yes">
				<cfscript>
					if ( lsIsDate(form.spViewDate) ) {
						session.speck.viewDate = lsParseDateTime(form.spViewDate);
						session.speck.showAdminLinks = false;
						session.speck.showCacheInfo = false;
					} else {
						session.speck.viewDate = "";
					}
					request.speck.session.viewDate = session.speck.viewDate;
					request.speck.session.showAdminLinks = session.speck.showAdminLinks;
					request.speck.session.showCacheInfo = session.speck.showCacheInfo;
				</cfscript>
				</cflock>
			
			</cfif>
			
			<!--- Render view date field --->
			<cfif request.speck.session.viewDate eq "">
			
				<cfset viewDate = stStrings.nowCaption>
				
			<cfelse>
			
				<cfset viewDate = dateFormat(request.speck.session.viewDate,"YYYY-MM-DD") & " " & timeFormat(request.speck.session.viewDate,"HH:mm")>
					
			</cfif>
			
			<cfset calendarURL = "/speck/properties/datetime/calendar.html?form=spToolbar&field=spViewDate&callback=spSetViewDate">
			
			<cfoutput>
			<script type="text/javascript">
				<!--
				//<![CDATA[
				function openCalendar_spToolbar(e) {
					if (!e) var e = window.event;
					var calendarWindow = window.open('#calendarURL#','calendar','width=225,height=160,left=' + e.screenX +',top=' + e.screenY + ',screenX=' + e.screenX +',screenY=' + e.screenY);
					calendarWindow.focus();
					return false;
				}
				//]]>
				//-->
			</script>
			#stStrings.viewDate# <input class="spToolbar" title="Click to set view date to 'Now'" onclick="this.value='';spSetViewDate();" readonly="yes" style="background:##eeeeee;width:120px" type="text" name="spViewDate" value="#viewDate#" size="19" maxlength="30" onchange="spSetViewDate();" />
			<a href="javascript:return false;"
				class="spViewDate"
				onclick="openCalendar_spToolbar(event);return false;"		
				title="#request.speck.buildString("P_DATE_CALENDAR_CAPTION")#"><span><img class="spToolbar" src="/speck/properties/datetime/calendar_blue.gif" border="0" /></span></a>
			</cfoutput>
				
		</cfif>
		
		<cfscript>
		
			// admin links checkbox
			if ( request.speck.session.showAdminLinks )
				adminLinksChecked = "checked=""yes""";
			else
				adminLinksChecked = "";
				
			// cache info checkbox
			if ( request.speck.session.showCacheInfo )
				cacheInfoChecked = "checked=""yes""";
			else
				cacheInfoChecked = "";			
			
			// disable checkboxes?
			if ( not request.speck.session.viewDate eq "" )
				disabled = "disabled=""yes""";
			else
				disabled = "";
		
		</cfscript>
	
		<cfoutput>
		<span class="spToolbar spShowAdminLinks">
		#stStrings.showAdminLinks# <input class="spToolbar checkbox" type="checkbox" name="spShowAdminLinks" value="yes" #adminLinksChecked# #disabled# onclick="spToggleAdminLinks();" />
		</span>
		</cfoutput>
		<cfif request.speck.userHasPermission("spSuper")>
			<cfoutput>
			<span class="spToolbar spShowCacheInfo">
			#stStrings.showCacheInfo# <input class="spToolbar checkbox" type="checkbox" name="spShowCacheInfo" value="yes" #cacheInfoChecked# #disabled# onclick="spToggleCacheInfo();" />
			</span>
			</cfoutput>
		</cfif>
		<cfif request.speck.userHasPermission("spLive,spSuper")>
			<cfoutput>
			<a class="spToolbar spResetCache" href="#request.speck.resetCacheURL#" title="#stStrings.resetCacheTooltip#">#stStrings.resetCache#</a>
			</cfoutput>
		</cfif>
		<cfif attributes.manageKeywords and findNoCase("spKeywords",request.speck.keywordsSources) and request.speck.userHasPermission("spSuper,spKeywords")>
		
			<cfif isDefined("request.speck.portal.qKeyword") and request.speck.portal.qKeyword.recordCount and ( request.speck.userHasPermission("spSuper,spEdit") or ( len(request.speck.portal.qKeyword.roles) and request.speck.userHasPermission(request.speck.portal.qKeyword.roles) ) )>
			
				<!--- force spContent to output all the admin functions, but without returning any content or outputting any links --->
				<cf_spContent type="spKeywords" enableAdminLinks="yes" enableAddLink="no" maxRows="0">
				<cfoutput>
				<a class="spToolbar spEditKeyword" href="javascript:launch_edit('spKeywords','#request.speck.portal.qKeyword.spId#', '', '','Navigation Section');" title="Edit settings for the current page/section">Page Settings</a>
				</cfoutput>
			
			</cfif>
			
			<cfif isDefined("request.speck.portal")>
				<cfset windowWidth = 800>
				<cfset windowHeight = 600>
			<cfelse>
				<cfset windowWidth = 650>
				<cfset windowHeight = 500>
			</cfif>
			<cfoutput>
			<script type="text/javascript">
				<!--
				//<![CDATA[
				function launch_keywords() {
					var keywordsWin = window.open("/speck/admin/keywords.cfm?app=#request.speck.appname#", "manage_keywords", "menubar=no,scrollbars=yes,resizable=yes,width=#windowWidth#,height=#windowHeight#,screenX=125,screenY=25,left=125,top=25");
					keywordsWin.focus();
				}
				//]]>
				//-->
			</script>
			<a class="spToolbar spManageKeywords" href="javascript:launch_keywords();" title="#stStrings.manageKeywordsTooltip#">#stStrings.manageKeywords#</a>
			</cfoutput>
			
		</cfif>
		
		<cfif isDefined("request.speck.portal")>
		
			<cfif structKeyExists(application.speck.securityZones,"portal") and request.speck.userHasPermission("spSuper,spUsers")>
				
				<cfoutput>
				<script type="text/javascript">
					<!--
					//<![CDATA[
					function launch_users() {
						var usersWin = window.open("/speck/portal/users.cfm?app=#request.speck.appname#", "manage_users", "menubar=no,scrollbars=yes,resizable=yes,width=800,height=600,screenX=125,screenY=25,left=125,top=25");
						usersWin.focus();
					}
					//]]>
					//-->
				</script>
				<a href="javascript:launch_users();" class="spToolbar spManageUsers" title="Manage users, groups and roles">Users</a>
				</cfoutput>
				
			</cfif>
			
			<!--- experimental code to for CF file manager integration --->
			<cfparam name="request.speck.portal.fileManager" default="false" type="boolean">
			<cfparam name="request.speck.portal.fileManagerUsers" default="">
			<cfparam name="request.speck.portal.fileManagerIps" default="">
			<cfset request.speck.portal.fileManagerIps = reReplace(request.speck.portal.fileManagerIps,"[[:space:]]+","","all")>
			
			<!--- To use the file manager, must have spSuper role AND be in the list of file manager users or be accessing from list of allowed ips --->
			<!--- probable TODO: add a new spDeveloper role and require that role rather than spSuper --->
				
			<cfif request.speck.portal.fileManager 
				and request.speck.userHasPermission("spSuper") 
				and ( listFindNoCase(request.speck.portal.fileManagerUsers,request.speck.session.user) or listFindNoCase(request.speck.portal.fileManagerIps,cgi.REMOTE_ADDR) )>
				
				<cfoutput>
				<script type="text/javascript">
				<!--
				//<![CDATA[
				function launch_filemanager() {
				        var fileManagerWin = window.open("/speck/filemanager/index.cfm?app=#request.speck.appName#", "file_manager", "menubar=no,scrollbars=yes,resizable=yes,width=800,height=600,screenX=125,screenY=25,left=125,top=25");
				        fileManagerWin.focus();
				}
				//]]>
				//-->
				</script>
				<a class="spToolbar spFileManager" href="javascript:launch_filemanager();">File Manager</a>
				</cfoutput>
				
			</cfif>
		
		</cfif>
		
		<!--- insert any html into the toolbar?? --->
		<cfif len(request.speck.toolbarInsert)>
			
			<cfoutput>#request.speck.toolbarInsert#</cfoutput>
	
		</cfif>
		
		<cfif isDefined("request.speck.portal") and request.speck.userHasPermission("spSuper")>
			
			<cfoutput>
			<a href="#cgi.script_name#?refreshapp=1&amp;requestTimeout=90" class="spToolbar spRefreshApp" title="Refresh application / reload configuration" onclick="return confirm('Refresh application \'#request.speck.appName#\'?\n\nThis also resets all content caches, which will result \nin slower response times until caches are re-built.');">Refresh App</a>
			</cfoutput>
			
		</cfif>
		
		<cfoutput>
		</form>
		</td>
		</cfoutput>
		
		<!--- logout form --->
		<cfoutput>
		<td class="spToolbar spLogout">
		<a href="javascript:spLogout();" class="spToolbar spLogout">#stStrings.logoutCaption#</a>
		<!--- <a href="/speck/logout.cfm?app=#request.speck.appName#" class="spToolbar spLogout">#stStrings.logoutCaption#</a> --->
		<!--- <form name="spLogout" class="spToolbar spLogout" method="post" action="#refreshURL#" style="padding:0;margin:0;">
		<a href="javascript:document.forms['spLogout'].submit();" class="spToolbar spLogout">#stStrings.logoutCaption#</a>
		<input type="hidden" name="spLogout" id="spLogout" value="1" />
		</form> --->
		</td>
		</cfoutput>
		
		<cfoutput></tr></table></cfoutput>
		
	</cfif>

</cfif>