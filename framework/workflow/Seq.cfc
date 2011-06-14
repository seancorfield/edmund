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
		<cfargument name="commandArray" type="array" required="true" hint="edmund.framework.workflow.ICommand[]" />
			
		<cfset variables.commandArray = arguments.commandArray />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" hint="">
		<cfargument name="event" type="edmund.framework.Event" required="true" />

		<cfset var command = 0 />
		<cfset var result = true />
		
		<cfloop index="command" array="#variables.commandArray#">

			<cfset result = result and command.handleEvent(arguments.event) />
			<cfif not result>
				<cfbreak />
			</cfif>

		</cfloop>
		
		<cfreturn result />
		
	</cffunction>

</cfcomponent>