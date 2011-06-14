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

<cfcomponent hint="I handle a sequence of event handling listeners." output="false">

	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the constructor.">
		<cfargument name="events" type="string" required="true" hint="I am a list of events to trigger" />
		<cfargument name="edmund" type="any" required="true" hint="I am the event framework." />
		
		<cfset variables.events = arguments.events />
		<cfset variables.edmund = arguments.edmund />
		
		<cfreturn this />
			
	</cffunction>

	<cffunction name="handleEvent" returntype="void" access="public" output="false" hint="I am the event listener.">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var item = "" />
		
		<cfloop index="item" list="#variables.events#">
			
			<cfset variables.edmund.dispatchAliasEvent(item,arguments.event) />
			
		</cfloop>
		
	</cffunction>

</cfcomponent>