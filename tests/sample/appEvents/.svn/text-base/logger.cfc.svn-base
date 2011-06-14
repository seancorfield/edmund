<!--- extends ICommand because we're using it in workflow as well as being just a regular event handler --->
<cfcomponent implements="edmund.framework.workflow.ICommand" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="prefix" type="string" required="true" />
		
		<cfset variables.prefix = arguments.prefix />
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" 
				hint="I handle an event - I just log the information.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset var i = 0 />
		<cfset var values = arguments.event.all() />
		<cfset var logOutput = "#variables.prefix# : logger.handleEvent(#arguments.event.name()#)" />
		<cfloop item="i" collection="#values#">
			<cfif isSimpleValue(values[i])>
				<cfset logOutput = logOutput & " - #i# = #values[i]#" />
			<cfelse>
				<cfset logOutput = logOutput & " - #i# = #values[i].toString()#" />
			</cfif>
		</cfloop>
		<cflog application="true" text="#logOutput#" type="information" log="application" />
		
		<cfreturn true />

	</cffunction>

</cfcomponent>