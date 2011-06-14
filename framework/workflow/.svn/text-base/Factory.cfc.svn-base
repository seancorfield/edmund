<cfcomponent hint="I am the workflow object factory." output="false">

	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the constructor.">
		<cfargument name="logger" type="edmund.framework.Logger" required="true" 
					hint="I am the logging component." />

		<cfset variables.logger = arguments.logger />

		<cfreturn this />
	
	</cffunction>
	
	<cffunction name="decision" returntype="any" access="public" output="false" hint="I return a decision workflow object.">
		<cfargument name="condition" type="edmund.framework.workflow.ICommand" required="true" />
		<cfargument name="ifTrue" type="edmund.framework.workflow.ICommand" required="true" />
		<cfargument name="else" type="edmund.framework.workflow.ICommand" required="false" />
			
		<cfreturn createObject("component","edmund.framework.workflow.Decision").init(argumentCollection=arguments) />
	
	</cffunction>

	<cffunction name="foreach" returntype="any" access="public" output="false" hint="I return a foreach loop workflow object.">
		<cfargument name="iterator" type="string" required="true" />
		<cfargument name="it" type="string" required="true" />
		<cfargument name="body" type="edmund.framework.workflow.ICommand" required="true" />
			
		<cfreturn createObject("component","edmund.framework.workflow.ForEach").init(argumentCollection=arguments) />
	
	</cffunction>

	<cffunction name="loop" returntype="any" access="public" output="false" hint="I return a conditional loop workflow object.">
		<cfargument name="condition" type="edmund.framework.workflow.ICommand" required="true" />
		<cfargument name="body" type="edmund.framework.workflow.ICommand" required="true" />
			
		<cfreturn createObject("component","edmund.framework.workflow.Loop").init(argumentCollection=arguments) />
	
	</cffunction>

	<cffunction name="noop" returntype="any" access="public" output="false" hint="I return a no-op workflow object.">
			
		<cfreturn createObject("component","edmund.framework.workflow.NoOp").init(argumentCollection=arguments) />
	
	</cffunction>

	<cffunction name="seq" returntype="any" access="public" output="false" hint="I return a sequence workflow object.">
		<cfargument name="commandArray" type="array" required="true" hint="edmund.framework.workflow.ICommand[]" />
			
		<cfreturn createObject("component","edmund.framework.workflow.Seq").init(argumentCollection=arguments) />
	
	</cffunction>

</cfcomponent>