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

<cfcomponent implements="ICommand" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false" hint="">
		<cfargument name="condition" type="edmund.framework.workflow.ICommand" required="true" />
		<cfargument name="ifTrue" type="edmund.framework.workflow.ICommand" required="true" />
		<cfargument name="else" type="edmund.framework.workflow.ICommand" required="false" />
				
		<cfset variables.condition = arguments.condition />
		<cfset variables.ifTrue = arguments.ifTrue />
		<cfif structKeyExists(arguments,"else")>
			<cfset variables.else = arguments.else />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" hint="">
		<cfargument name="event" type="edmund.framework.Event" required="true" />

		<cfif variables.condition.handleEvent(arguments.event)>

			<cfreturn variables.ifTrue.handleEvent(arguments.event) />

		<cfelseif structKeyExists(variables,"else")>

			<cfreturn variables.else.handleEvent(arguments.event) />
			
		<cfelse>
		
			<cfreturn true />

		</cfif>

	</cffunction>

</cfcomponent>