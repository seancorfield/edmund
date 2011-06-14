<cfcomponent>

	<cfset variables.history = [ ] />

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="doNotHandle" type="string" default="" />

		<cfset variables.doNotHandle = arguments.doNotHandle />

		<cfreturn this />
		
	</cffunction>

	<cffunction name="onMissingMethod" returntype="boolean" access="public" output="false">
		<cfargument name="missingMethodName" type="string" required="true" />
		<cfargument name="missingMethodArguments" type="struct" required="true" />

		<cfset var event = 0 />
		<cfset var action = 0 />
		<cfset var args = structKeyList(arguments.missingMethodArguments) />

		<!--- there should just be one argument --->
		<cfset event = arguments.missingMethodArguments[listFirst(args)] />
		<cfset action = { name = event.name(), requestName = event.requestName(), 
							bubble = event.bubble(), values = event.all(),
							handlerName = missingMethodName } />
		<cfset arrayAppend(variables.history,action) />

		<cfreturn listFind(variables.doNotHandle,action.name) eq 0 />

	</cffunction>

	<cffunction name="getHistory" returntype="array" access="public" output="false">
		
		<cfreturn variables.history />

	</cffunction>

	<cffunction name="called" returntype="struct" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		
		<cfreturn matched(arguments.name,"handlerName") />

	</cffunction>

	<cffunction name="handled" returntype="struct" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		
		<cfreturn matched(arguments.name,"name") />

	</cffunction>

	<cffunction name="matched" returntype="struct" access="private" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="attribute" type="string" required="true" />
		
		<cfset var item = 0 />

		<cfloop index="item" array="#variables.history#">
			<cfif item[arguments.attribute] is arguments.name>
				<cfreturn item />
			</cfif>
		</cfloop>

		<!--- no match, return an empty action populated with empty items --->
		<cfset item = { name = "", requestName = "", bubble = false, values = { }, handlerName = "" } />

		<cfreturn item />

	</cffunction>

</cfcomponent>