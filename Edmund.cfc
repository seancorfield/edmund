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

<cfcomponent hint="I am the main entry point for the framework." output="false">

	<!---
		the only reason we track children is to keep them accessible from a parent context
		for GC purposes - you don't want your children to be collected while your parent
		context is still active
	--->
	<cfset variables.parent = 0 />
	<cfset variables.children = structNew() />
	<cfset variables.uniqueId = createUUID() />
	
	<!--- constructor --->
	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the framework constructor.">
		<cfargument name="ignoreAsync" type="boolean" default="false"
					hint="I indicate whether async mode should fallback to sync mode on servers that do not support it." />
		<cfargument name="logging" type="string" default="" 
					hint="I indicate if or where to do logging: I can be empty - no logging - or the name of a log file." />
		<cfargument name="parent" type="edmund.Edmund" required="false" 
					hint="I am an optional event context - another instance of Edmund." />
		
		<!--- save settings for child/parent creation --->
		<cfset variables.ignoreAsync = arguments.ignoreAsync />
		<cfset variables.logging = arguments.logging />
		
		<cfset variables.logger = createObject("component","edmund.framework.Logger").init(arguments.logging) />

		<cfset variables.loader = createObject("component","edmund.framework.Loader").init(this,variables.logger) />
		<cfset variables.workflow = createObject("component","edmund.framework.workflow.Factory").init(variables.logger) />

		<cfif structKeyExists(arguments,"parent")>
			<cfset setParent(arguments.parent) />
		</cfif>

		<cfset variables.handler = createObject("component","edmund.framework.EventHandler").init(this,arguments.ignoreAsync,variables.logger) />
		
		<cfreturn this />
			
	</cffunction>
	
	<!--- XML loaders --->
	<cffunction name="load" returntype="any" access="public" output="false" 
				hint="I load event / listener definitions from an XML file.">
		<cfargument name="file" type="string" required="true" 
					hint="I am the full filesystem path of the XML file to load.">
	
		<cfset variables.loader.load(arguments.file) />
		
		<cfreturn this />
	
	</cffunction>
	
	<cffunction name="loadXML" returntype="any" access="public" output="false" 
				hint="I load event / listener definitions from an XML string or object.">
		<cfargument name="xmlData" type="any" required="true" 
					hint="I am the XML string or object from which to load the definitions.">
	
		<cfset variables.loader.loadXML(arguments.xmlData) />
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- retrieve workflow factory --->
	<cffunction name="getWorkflow" returntype="any" access="public" output="false" hint="I return the workflow factory.">
	
		<cfreturn variables.workflow />
	
	</cffunction>
	
	<!--- convenience method to create new events by class name --->
	<cffunction name="new" returntype="any" access="public" output="false" 
				hint="I return a new event. Usage: new(className) or new().name(eventName) or new(class=className,otherArgs).name(eventName).">
		<cfargument name="class" type="string" default="edmund.framework.Event" 
					hint="I am the name of the new event class." />
					
		<cfreturn createObject("component",arguments.class).init(this,listLast(arguments.class,"."),arguments) />

	</cffunction>
	
	<!--- convenience method to create new events by event name --->
	<cffunction name="newEvent" returntype="any" access="public" output="false" 
				hint="I return a new event. Usage: newEvent(eventName). Equivalent to: new().name(eventName).">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the new event." />
		
		<cfreturn new().name(arguments.name) />

	</cffunction>
	
	<!--- context creation methods --->
	<cffunction name="newChild" returntype="any" access="public" output="false" hint="I return a new child event context.">
	
		<cfreturn createObject("component","edmund.Edmund").init(variables.ignoreAsync,variables.logging,this) />
	
	</cffunction>
	
	<cffunction name="newParent" returntype="any" access="public" output="false" hint="I return a new parent event context.">
	
		<cfset var newParent = createObject("component","edmund.Edmund").init(variables.ignoreAsync,variables.logging) />
		
		<cfset setParent(newParent) />
		
		<cfreturn newParent />
	
	</cffunction>
	
	<!--- parent / child convenience methods --->
	<cffunction name="addChild" returntype="void" access="public" output="false" 
				hint="I add a new child context (and set this as a parent of that child).">
		<cfargument name="child" type="any" required="true" hint="I am the new child context." />
		
		<cfif not structKeyExists(variables.children,arguments.child.getId())>
			<cfset variables.children[arguments.child.getId()] = arguments.child />
			<cfset arguments.child.setParent(this) />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getId" returntype="string" access="public" output="false" hint="I return this event context's unique ID.">
	
		<cfreturn variables.uniqueId />
	
	</cffunction>
	
	<cffunction name="getParent" returntype="any" access="public" output="false" hint="I return this event context's parent.">
	
		<cfreturn variables.parent />
	
	</cffunction>
	
	<cffunction name="setParent" returntype="void" access="public" output="false" 
				hint="I set a parent (and add this child to that parent).">
		<cfargument name="parent" type="any" required="true" hint="I am the new parent context." />
		
		<cfif not isObject(variables.parent) or variables.parent.getId() is not arguments.parent.getId()>
			<cfset variables.parent = arguments.parent />
			<cfset variables.parent.addChild(this) />
		</cfif>
		
	</cffunction>
	
	<!--- registration points for listeners --->
	<cffunction name="addEventListener" returntype="any" access="public" output="false" 
				hint="I register a new event handler using the Flex approach (but I take an object, not a function). See register() method for usage.">

		<cfreturn register(argumentCollection=arguments) />
		
	</cffunction>
	
	<cffunction name="register" returntype="any" access="public" output="false" 
				hint="I register a new event handler using the original Edmund syntax.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the event to listen for." />
		<cfargument name="listener" type="any" required="true" 
					hint="I am the listener object." />
		<cfargument name="method" type="string" default="handleEvent" 
					hint="I am the method to call on the listener when the event occurs." />
		<cfargument name="async" type="boolean" default="false"
					hint="I specify whether the listener should be invoked asynchronously." />

		<cfset variables.handler.addListener(argumentCollection=arguments) />
		
		<cfreturn this />
		
	</cffunction>
	
	<!--- dispatch event by name --->
	<cffunction name="dispatch" returntype="void" access="public" output="false" 
				hint="I dispatch an event by name, with no values.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the name of the event to be handled." />
		
		<cfset dispatchEvent( new().name(arguments.eventName) ) />

	</cffunction>
	
	<!--- dispatch event by object --->
	<cffunction name="dispatchEvent" returntype="void" access="public" output="false" 
				hint="I dispatch an event.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset dispatchAliasEvent(arguments.event.name(),arguments.event) />

	</cffunction>
	
	<!--- dispatch event by name and object --->
	<cffunction name="dispatchAliasEvent" returntype="void" access="public" output="false" 
				hint="I dispatch an event.">
		<cfargument name="eventAlias" type="string" required="true" 
					hint="I am the name of the event to be handled." />
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset variables.handler.handleEvent(arguments.eventAlias,arguments.event) />

	</cffunction>
	
	<!--- hooks for Application.cfc usage --->
	<cffunction name="onApplicationStart"
				hint="I can be called at the end of onApplicationStart, once all the listeners are registered.">
		
		<cfset dispatchEvent( new().name("onApplicationStart") ) />
		
	</cffunction>

	<cffunction name="onSessionStart"
				hint="I can be called from onSessionStart.">
		
		<cfset dispatchEvent( new().name("onSessionStart") ) />
		
	</cffunction>

	<cffunction name="onRequestStart"
				hint="I can be called from onRequestStart.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestStart)." />
					
		<cfset dispatchEvent( new().name("onRequestStart").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onRequestEnd"
				hint="I can be called from onRequestEnd.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestEnd)." />
					
		<cfset dispatchEvent( new().name("onRequestEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onSessionEnd"
				hint="I can be called from onSessionEnd.">
		<cfargument name="sessionScope" required="false" 
					hint="I am the sessionScope (argument to Application.onSessionEnd)." />
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onSessionEnd)." />
					
		<cfset dispatchEvent( new().name("onSessionEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onApplicationEnd"
				hint="I can be called from onApplicationEnd.">
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onApplicationEnd)." />
					
		<cfset dispatchEvent( new().name("onApplicationEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onError"
				hint="I can be called from onError.">
		<cfargument name="exception" required="false" 
					hint="I am the exception (argument to Application.onError)." />
		<cfargument name="eventName" type="string" required="false" 
					hint="I am the eventName (argument to Application.onError)." />
					
		<cfset dispatchEvent( new().name("onError").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<!--- hooks for bean factory usage --->
	<cffunction name="setBeanFactory" returntype="void" access="public" output="false" 
				hint="I allow a bean factory to be injected.">
		<cfargument name="beanFactory" type="any" required="true" 
					hint="I am a bean factory.">
		
		<cfset variables.beanFactory = arguments.beanFactory />
		
	</cffunction>
	
	<cffunction name="hasBeanFactory" returntype="boolean" access="public" output="false" 
				hint="I return true if a bean factory was injected.">
		
		<cfreturn structKeyExists(variables,"beanFactory") />
		
	</cffunction>
	
	<cffunction name="getBeanFactory" returntype="any" access="public" output="false" 
				hint="I return the bean factory.">
		
		<cfreturn variables.beanFactory />
		
	</cffunction>
	
</cfcomponent>