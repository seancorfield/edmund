<cfcomponent output="false">

	<cfset this.NAME = "edmund_cfspec" />
	<cfset this.mappings["/edmund"] = getDirectoryFromPath( getCurrentTemplatePath() ) & "../../" />

</cfcomponent>