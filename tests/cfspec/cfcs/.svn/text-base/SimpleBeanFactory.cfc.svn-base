<cfcomponent>

	<cffunction name="init" returntype="any" access="public" output="false">

		<cfset variables.beans = { } />

		<cfreturn this />

	</cffunction>

	<cffunction name="addBean" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="bean" type="any" required="true" />

		<cfset variables.beans[arguments.name] = arguments.bean />

		<cfreturn this />

	</cffunction>

	<cffunction name="getBean" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfreturn variables.beans[arguments.name] />

	</cffunction>

</cfcomponent>