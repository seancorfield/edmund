<!--- example showing xml event configuration --->
<cfcomponent output="false">
	
	<cfset this.name = "edmund_sample_using_xml" />
	<cfset this.sessionmanagement = true />
	<cfset this.sessiontimeout = createTimeSpan(0,0,1,0) />
	<cfset this.applicationtimeout = createTimeSpan(0,0,2,0) />

	<cffunction name="onApplicationStart">
		
		<cfset loadEdmund() />

	</cffunction>
	
	<cffunction name="onRequestStart">
	
		<cfif structKeyExists(URL,"reload") and URL.reload>
			<cfset loadEdmund() />
		</cfif>
	
	</cffunction>
	
	<cffunction name="loadEdmund" returntype="void" access="private" output="false">
			
		<!--- create edmund system: ignoreAsync if server does not support it --->
		<cfset application.edmund = createObject("component","edmund.Edmund").init(ignoreAsync=true,logging="edmund").load(expandPath("edmund.xml")) />
		
	</cffunction>

</cfcomponent>