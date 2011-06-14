<!---
 
  Copyright (c) 2008-2009, Sean Corfield, Pat Santora
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

---> 

<cfcomponent output="false" hint="I represent an event.">
	
	<cfset variables.eventName = "[unnamed event]" />
	<cfset variables.eventRequestName = "[unnamed event]" />
	<cfset variables.eventValues = structNew() />
	<cfset variables.bubbleUp = false />
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the event constructor.">
		<cfargument name="edmund" type="any" required="true" 
					hint="I am the Edmund framework." />
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the name of this event." />
		<cfargument name="eventValues" type="struct" default="#structNew()#" 
					hint="I am the optional initial values for this event." />
		<cfargument name="bubble" type="boolean" default="false"
					hint="I indicate whether this event should bubble up after being handled." />

		<cfset variables.edmund = arguments.edmund />
		<cfset variables.eventName = arguments.eventName />
		<cfset variables.eventRequestName = arguments.eventName />
		<cfset variables.bubbleUp = arguments.bubble />
		<!--- we always reuse the same struct and copy in event values to prevent accidental overwriting of other event object contents --->
		<cfset structClear(variables.eventValues) />
		<cfset structAppend(variables.eventValues,arguments.eventValues) />
		
		<cfset configure() />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="configure" returntype="void" access="public" output="false" hint="Override me to provide initialization logic.">
	</cffunction>
	
	<cffunction name="all" returntype="struct" access="public" output="false" 
				hint="I return a shallow copy of all the event values.">
	
		<cfreturn structCopy(variables.eventValues) />
	
	</cffunction>
	
	<cffunction name="bubble" returntype="any" access="public" output="false">
		<cfargument name="bubbleUp" type="string" required="false" 
					hint="I am the new bubble up setting. If omitted, this method returns the current bubble up setting." />
	
		<cfif structKeyExists(arguments,"bubbleUp")>
			<cfset variables.bubbleUp = arguments.bubbleUp />
			<cfreturn this />
		<cfelse>
			<cfreturn variables.bubbleUp />
		</cfif>
	
	</cffunction>
	
	<cffunction name="dispatch" returntype="void" access="public" output="false" hint="I dispatch myself.">
	
		<cfset variables.edmund.dispatchEvent(this) />
	
	</cffunction>
	
	<cffunction name="has" returntype="boolean" access="public" output="false" 
				hint="I return true iff the specified value exists in the event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the value to test for." />

		<cfreturn structKeyExists(variables.eventValues,arguments.name) />

	</cffunction>

	<cffunction name="name" returntype="any" access="public" output="false">
		<cfargument name="eventName" type="string" required="false" 
					hint="I am the new name for the event. If omitted, this method returns the current event name." />
	
		<cfif structKeyExists(arguments,"eventName")>			
			<cfset variables.eventName = arguments.eventName />
			<cfset variables.eventRequestName = arguments.eventName />
			<cfreturn this />
		<cfelse>
			<cfreturn variables.eventName />
		</cfif>
	
	</cffunction>
	
	<cffunction name="requestName" returntype="any" access="public" output="false"
		hint="Sets the event name that started the request lifecycle.">
		<cfargument name="eventRequestName" type="string" required="false"
					hint="A request name for this event. If omitted, this method returns the current request name." />
					
		<cfif structKeyExists(arguments,"eventRequestName")>
			<cfset variables.eventRequestName = arguments.eventRequestName />
			<cfreturn this />
		<cfelse>
			<cfreturn variables.eventRequestName />
		</cfif>
		
	</cffunction>
	
	<cffunction name="value" returntype="any" access="public" output="false" 
				hint="I either return a value from the event or store a value in the event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the value to store." />
		<cfargument name="value" type="any" required="false" 
					hint="I am the new value to store." />
			
		<cfif structKeyExists(arguments,"value")>
			<cfset variables.eventValues[arguments.name] = arguments.value />
			<cfreturn this />
		<cfelse>
			<cfreturn variables.eventValues[arguments.name] />
		</cfif>
			
	</cffunction>
	
	<cffunction name="values" returntype="any" access="public" output="false" 
				hint="I set event values. I take an arbitrary list of named arguments.">

		<cfset var i = 0 />
		
		<cfloop item="i" collection="#arguments#">
			<!--- only set named arguments, not positional arguments --->
			<cfif not isNumeric(i)>
				<cfset value(i,arguments[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn this />

	</cffunction>
	
</cfcomponent>