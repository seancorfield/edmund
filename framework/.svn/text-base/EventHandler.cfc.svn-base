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

<cfcomponent hint="I am the primary event handler." output="false">

	<cfset variables.registry = structNew() />
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the event handler constructor.">
		<cfargument name="context" type="any" required="true" 
					hint="I am the owning context, an instance of Edmund." />
		<cfargument name="ignoreAsync" type="boolean" required="true"
					hint="I indicate whether async mode should fallback to sync mode on servers that do not support it." />
		<cfargument name="logger" type="edmund.framework.Logger" required="true" 
					hint="I am the logging component." />

		<cfset variables.context = arguments.context />
		<cfset variables.ignoreAsync = arguments.ignoreAsync />
		<cfset variables.logger = arguments.logger />
		<cfset setUpThreadingModel() />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="addListener" returntype="void" access="public" output="false" 
				hint="I add a listener for the specified event.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the event to listen for." />
		<cfargument name="listener" type="any" required="true" 
					hint="I am the listener object." />
		<cfargument name="method" type="string" default="handleEvent" 
					hint="I am the method to call on the listener when the event occurs." />
		<cfargument name="async" type="boolean" default="false"
					hint="I specify whether the listener should be invoked asynchronously." />

		<cfset var tuple = structNew() />
		
		<cfset tuple.listener = arguments.listener />
		<cfset tuple.method = arguments.method />
		<cfset tuple.async = arguments.async />
		
		<cfif arguments.async and threadingIsNotSupported()>
			<cfif variables.ignoreAsync>
				<cfset tuple.async = false />
			<cfelse>
				<cfthrow type="edmund.asyncNotSupported" 
						message="Asynchronous listeners are not supported on this server" 
						detail="This server does not support the necessary threading model to allow asynchronous listeners." />
			</cfif>
		</cfif>
		
		<cflock name="#application.ApplicationName#_edmund_eventhandler_addListener_#arguments.eventName#" type="exclusive" timeout="10">
			<cfif not structKeyExists(variables.registry,arguments.eventName)>
				<cfset variables.registry[arguments.eventName] = arrayNew(1) />
			</cfif>
			<cfset arrayAppend(variables.registry[arguments.eventName],tuple) />
		</cflock>
		
		<cfset variables.logger.info("Registered listener for event '#arguments.eventName#'") />

	</cffunction>
	
	<cffunction name="handleEvent" returntype="void" access="public" output="false" 
				hint="I handle an event by invoking any registered listeners.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the name of the event to be handled." />	
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event data to be used by the handler." />

		<cfset var name = arguments.eventName />
		<cfset var requestName = arguments.event.requestName() />
		<cfset var handler = 0 />
			
		<!--- need to figure out if this is an attempt to announce a new event so we can adjust the event name --->	
		<cfif left( name, len("{event}") ) is "{event}">
			<cfset name = right(name, len(name)-len("{event}") )  />
			<!--- we rename the event but restore the request name --->
			<cfset arguments.event.name( name ).requestName( requestName ) />
			
			<cfset variables.logger.info("Announcing event '#name#'") />
		</cfif>
		
		<cfif structKeyExists(variables.registry,name)>

			<cfset variables.logger.info("Handling event '#name#'") />
		
			<cfparam name="request.__edmund_event_handling" default="#structNew()#" />
			<cfif structKeyExists(request.__edmund_event_handling,name) and
					request.__edmund_event_handling[name]>
				<cfthrow type="edmund.recursiveEvent" 
						message="Event dispatched recursively" 
						detail="An attempt was made to dispatch the '#name#' event while an active handler for that event was already in progress." />
			<cfelse>
				<cfset request.__edmund_event_handling[name] = true />
			</cfif>
			
			<cftry>

				<cfloop index="handler" array="#variables.registry[name]#">
					<cfif handler.async>
						<cfset variables.threadingModel.asyncInvoke(handler.listener,handler.method,arguments.event) />
					<cfelse>
						<cfinvoke component="#handler.listener#" method="#handler.method#">
							<cfinvokeargument name="event" value="#arguments.event#" />
						</cfinvoke>
					</cfif>
				</cfloop>

			<cfcatch type="any">
				<cfset request.__edmund_event_handling[name] = false />
				<cfrethrow />
			</cfcatch>
			
			</cftry>

			<cfset request.__edmund_event_handling[name] = false />
			
			<cfif isObject(variables.context.getParent()) and arguments.event.bubble()>
				
				<!--- we handled the event but it is set to bubble up and we actually have a parent to send it to --->
				<cfset variables.context.getParent().dispatchAliasEvent(arguments.eventName,arguments.event) />
				
			</cfif>
			
		<cfelseif isObject(variables.context.getParent())>
		
			<!--- no handler here, try our parent --->
			<cfset variables.context.getParent().dispatchAliasEvent(arguments.eventName,arguments.event) />
		
		<cfelse>
		
			<!--- TODO: issue a warning for now - with bubbling we may need to suppress this? --->
			<cfset variables.logger.warn("No listener registered for event '#name#'") />
		
		</cfif>

	</cffunction>
	
	<cffunction name="setUpThreadingModel" returntype="void" access="private" output="false" 
				hint="I determine whether threading is supported and how it is supported.">

		<cfset variables.serverSupportsThreading = false />
		
		<cfif server.ColdFusion.ProductName is "coldfusion server" or server.ColdFusion.ProductName is "Railo">
			<cfif listFirst(server.ColdFusion.ProductVersion) gte 8>
				<cfset variables.serverSupportsThreading = true />
				<cfset variables.threadingModel = createObject("component","edmund.framework.coldfusion.Threading").init() />
				<cfset variables.logger.info("Using ColdFusion/Railo threading model") />
			</cfif>
		<cfelseif server.ColdFusion.ProductName is "bluedragon">
			<cfif listFirst(server.ColdFusion.ProductVersion) gte 7>
				<cfset variables.serverSupportsThreading = true />
				<cfset variables.threadingModel = createObject("component","edmund.framework.bluedragon.Threading").init() />
				<cfset variables.logger.info("Using BlueDragon threading model") />
			</cfif>
		</cfif>
		
		<cfif threadingIsNotSupported()>
			<cfset variables.logger.info("No threading model available") />
		</cfif>
		
	</cffunction>
	
	<cffunction name="threadingIsNotSupported" returntype="boolean" access="private" output="false" 
				hint="I return true iff threading is not supported!">

		<cfreturn not variables.serverSupportsThreading />

	</cffunction>

</cfcomponent>