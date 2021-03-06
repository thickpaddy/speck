<cfsetting enablecfoutputonly="true">
<!---
This collective work is Copyright (C) 2001-2007 by Robin Hilliard (robin@zeta.org.au) and Mark Woods (mark@thickpaddy.com), 
All Rights Reserved. Individual portions may be copyright by individual contributors, and are included in this collective 
work with permission of the copyright owners.

Licensed under the Academic Free License version 2.1
--->

<cfif cgi.request_method eq "post">
	
	<!--- form posted --->
	
	<cfif len(url.rolename)>
	
		<!--- update group --->
		<cfquery name="qUpdate" datasource="#request.speck.codb#">

			UPDATE spRoles
			SET description = <cfif len(form.description)>'#form.description#'<cfelse>NULL</cfif>
			WHERE rolename = '#url.rolename#'
		
		</cfquery>
		
		<cfset message = "Role '#url.rolename#' updated">

		<cflocation url="action_response.cfm?app=#url.app#&message=#urlEncodedFormat(message)#&location=#urlEncodedFormat(form.referrer)#" addToken="no">


	<cfelse>
	
	
		<!--- validate rolename --->
		<cfif not len(form.rolename)>
		
			<cfset void = actionError("Role name is a required field.")>
			
		<cfelseif not REFind("^[A-Za-z0-9_\.]+$",form.rolename)>
				
			<cfset void = actionError("Role name contains invalid characters. Only letters, numbers, period and underscore are allowed.")>
			
		</cfif>
		
		<cfif not isDefined("actionErrors")>
		
			<!--- check that new rolename is not already in use before inserting --->

			<cfquery name="qCheckRole" datasource="#request.speck.codb#">
				SELECT rolename 
				FROM spRoles 
				WHERE UPPER(rolename) = '#uCase(form.rolename)#'
			</cfquery>
			
			<cfif qCheckRole.recordCount>
			
				<cfset void = actionError("Role name '#form.rolename#' is already in use, please choose another name.")>
				
			<cfelseif len(form.groupname)>
			
				<!--- check that group name is also not already in use --->
				<cfquery name="qCheckGroup" datasource="#request.speck.codb#">
					SELECT groupname 
					FROM spGroups 
					WHERE UPPER(groupname) = '#uCase(form.groupname)#'
				</cfquery>
				
				<cfif qCheckGroup.recordCount>
				
					<cfset void = actionError("Group name '#form.groupname#' is already in use, please choose another name.")>
					
				</cfif>
					
			
			</cfif>
			
		</cfif>
				
		<cfif not isDefined("actionErrors")>
			
			<!--- insert role --->
			<cfquery name="qInsert" datasource="#request.speck.codb#">
				INSERT INTO spRoles (
					rolename, 
					description
				) 
				VALUES (
					'#form.rolename#',
					<cfif len(form.description)>'#form.description#'<cfelse>NULL</cfif>
				)
			</cfquery>
			
			<cfif len(form.groupname)>
			
				<!--- insert group and connect group to role --->
				<cfquery name="qInsert" datasource="#request.speck.codb#">
					INSERT INTO spGroups (
						groupname, 
						description
					) 
					VALUES (
						'#form.groupname#',
						'Users with #form.rolename# role.'
					)
				</cfquery>
				<cfquery name="qDelete" datasource="#request.speck.codb#">
					DELETE FROM spRolesAccessors WHERE accessor = '#form.groupname#'
				</cfquery>
				<cfquery name="qInsert" datasource="#request.speck.codb#">
					INSERT INTO spRolesAccessors (
						rolename, 
						accessor
					) 
					VALUES (
						'#form.rolename#',
						'#form.groupname#'
					)
				</cfquery>				
			
			</cfif>
			
			<cfset message = "Role '#form.rolename#' added">

			<cflocation url="action_response.cfm?app=#url.app#&message=#urlEncodedFormat(message)#&location=#urlEncodedFormat(form.referrer)#" addToken="no">
		
		</cfif>
		
			
	</cfif>

</cfif>