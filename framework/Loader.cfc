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

<cfcomponent hint="I am the XML file loader." output="false">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="edmund" type="edmund.Edmund" required="true" 
					hint="I am the framework entry point.">
		<cfargument name="logger" type="edmund.framework.Logger" required="true" 
					hint="I am the logging component." />
		
		<cfset variables.edmund = arguments.edmund />
		<cfset variables.logger = arguments.logger />
		<cfset variables.listeners = structNew() />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="load" returntype="void" access="public" output="false" hint="I load and parse the XML file.">
		<cfargument name="file" type="string" required="true" 
					hint="I am the full filesystem path of the XML file to load.">

		<cfset var rawXML = 0 />
		
		<cfset variables.file = arguments.file />
		
		<cffile action="read" file="#arguments.file#" variable="rawXML" />
		
		<cfset loadDefinitions(rawXML) />
		
	</cffunction>

	<cffunction name="loadXML" returntype="void" access="public" output="false" hint="I load and parse a XML string or object.">
		<cfargument name="xmlData" type="any" required="true" 
					hint="I am the XML string or object from which to load the definitions.">
		
		<cfset variables.file = "-- XML Data --" />
		
		<cfset loadDefinitions(arguments.xmlData) />
		
	</cffunction>

	<cffunction name="loadDefinitions" returntype="void" access="private" output="false" hint="I load and parse a XML string or object.">
		<cfargument name="xmlData" type="any" required="true" 
					hint="I am the XML string or object from which to load the definitions.">

		<cfset var parsedXML = 0 />

		<cfif isSimpleValue(arguments.xmlData)>
			<cfset parsedXML = xmlParse(arguments.xmlData) />
		<cfelse>
			<cfset parsedXML = arguments.xmlData />
		</cfif>	

		<cfset loadListeners(parsedXML) />
		<cfset loadSubscribers(parsedXML) />
		<cfset loadControllers(parsedXML) />
		<cfset loadEventHandlers(parsedXML) />
		
	</cffunction>

	<cffunction name="loadListeners" returntype="void" access="private" output="false" 
				hint="I load listener declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//listeners/listener") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		
		<cfloop index="item" array="#items#">
			<!--- name, type|bean --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'listener' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>listeners>listener missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<cfif structKeyExists(item.xmlAttributes,"type")>
				<cfif structKeyExists(item.xmlAttributes,"bean")>
					<cfthrow type="edmund.conflictingAttributes" 
							message="'listener' declaration cannot have both 'type' and 'bean'" 
							detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' has both 'type' and 'bean' attributes in '#variables.file#'" />
				<cfelse>
					<!--- instantiate the listener --->
					<cfset obj = createObject("component",item.xmlAttributes.type) />
					<cfif structKeyExists(obj,"init") and isCustomFunction(obj.init)>
						<cfset obj.init() />
					</cfif>
					<!--- remember the listener --->
					<cfset variables.listeners[item.xmlAttributes.name] = obj />
				</cfif>
			<cfelseif structKeyExists(item.xmlAttributes,"bean")>
				<cfif not variables.edmund.hasBeanFactory()>
					<cfthrow type="edmund.badAttribute" 
							message="'bean' attribute requires bean factory support" 
							detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' has 'bean' attribute but Edmund has no bean factory in '#variables.file#'" />
				<cfelse>
					<!--- get the listener object from the factory --->
					<cfset variables.listeners[item.xmlAttributes.name] = variables.edmund.getBeanFactory().getBean(item.xmlAttributes.bean) />
				</cfif>
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'type' or 'bean' is required on 'listener' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' missing 'type' or 'bean' attribute in '#variables.file#'" />
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="loadSubscribers" returntype="void" access="private" output="false" 
				hint="I load subscriber declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//message-subscribers/message") />
		<cfset var item = 0 />
		<cfset var async = false />
		<cfset var obj = 0 />
		<cfset var children = 0 />
		<cfset var child = 0 />
		
		<cfloop index="item" array="#items#">
			<!--- name, multithreaded (optional: false) --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'message' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<!--- multithreaded is optional and defaults to false --->
			<cfset async = false />
			<cfif structKeyExists(item.xmlAttributes,"multithreaded")>
				<cfif listFind("false,true",item.xmlAttributes.multithreaded) gt 0>
					<cfset async = item.xmlAttributes.multithreaded is "true" />
				<cfelse>
					<cfthrow type="edmund.illegalAttribute" 
							message="'multithreaded' must be 'true' or 'false'" 
							detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message '#item.xmlAttributes.name#' has a multithreaded attribute of '#item.xmlAttributes.multithreaded#' which should be 'true' or 'false' in '#variables.file#'" />
				</cfif>
			</cfif>
			<!--- children(subscribe): listener, method --->
			<cfloop index="child" array="#item.xmlChildren#">
				<cfif child.xmlName is "subscribe">
					<cfif not structKeyExists(child.xmlAttributes,"listener")>
						<cfthrow type="edmund.missingAttribute" 
								message="'listener' is required on 'subscribe' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message '#item.xmlAttributes.name#'>subscribe missing 'listener' attribute in '#variables.file#'" />
					</cfif>
					<cfif not structKeyExists(variables.listeners,child.xmlAttributes.listener)>
						<cfthrow type="edmund.illegalAttribute" 
								message="'#child.xmlAttributes.listener#' is an unknown listener" 
								detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message '#item.xmlAttributes.name#'>subscribe '#child.xmlAttributes.listener#' was not declared as a listener in '#variables.file#'" />
					</cfif>
					<cfif not structKeyExists(child.xmlAttributes,"method")>
						<cfthrow type="edmund.missingAttribute" 
								message="'method' is required on 'subscribe' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message '#item.xmlAttributes.name#'>subscribe missing 'method' attribute in '#variables.file#'" />
					</cfif>
					<!--- register the subscriber --->
					<cfset variables.edmund.register(item.xmlAttributes.name,variables.listeners[child.xmlAttributes.listener],child.xmlAttributes.method,async) />
				<cfelse>
					<cfthrow type="edmund.unexpectedDeclaration" 
							message="Unexpected '#child.xmlName#' declaration found in 'message' declaration" 
							detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message '#item.xmlAttributes.name#'>#child.xmlName# is illegal inside a 'message' declaration in '#variables.file#'" />
				</cfif>
			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="loadControllers" returntype="void" access="private" output="false" 
				hint="I load controller declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//controllers/controller") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		<cfset var async = false />
		<cfset var children = 0 />
		<cfset var child = 0 />
		
		<cfloop index="item" array="#items#">
			<!--- name, type|bean --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'controller' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>controllers>controller missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<cfif structKeyExists(item.xmlAttributes,"type")>
				<cfif structKeyExists(item.xmlAttributes,"bean")>
					<cfthrow type="edmund.conflictingAttributes" 
							message="'controller' declaration cannot have both 'type' and 'bean'" 
							detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#' has both 'type' and 'bean' attributes in '#variables.file#'" />
				<cfelse>
					<!--- instantiate the listener --->
					<cfset obj = createObject("component",item.xmlAttributes.type) />
					<cfif structKeyExists(obj,"init") and isCustomFunction(obj.init)>
						<cfset obj.init() />
					</cfif>
					<!--- remember the listener --->
					<cfset variables.listeners[item.xmlAttributes.name] = obj />
				</cfif>
			<cfelseif structKeyExists(item.xmlAttributes,"bean")>
				<cfif not variables.edmund.hasBeanFactory()>
					<cfthrow type="edmund.badAttribute" 
							message="'bean' attribute requires bean factory support" 
							detail="#parsedXML.xmlRoot.xmlName#>controllers>controllers '#item.xmlAttributes.name#' has 'bean' attribute but Edmund has no bean factory in '#variables.file#'" />
				<cfelse>
					<!--- get the listener object from the factory --->
					<cfset variables.listeners[item.xmlAttributes.name] = variables.edmund.getBeanFactory().getBean(item.xmlAttributes.bean) />
				</cfif>
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'type' or 'bean' is required on 'controller' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#' missing 'type' or 'bean' attribute in '#variables.file#'" />
			</cfif>
			<!--- children(message-listener): message, function --->
			<cfloop index="child" array="#item.xmlChildren#">
				<cfif child.xmlName is "message-listener">
					<cfif not structKeyExists(child.xmlAttributes,"message")>
						<cfthrow type="edmund.missingAttribute" 
								message="'message' is required on 'message-listener' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#'>message-listener missing 'message' attribute in '#variables.file#'" />
					</cfif>
					<cfif not structKeyExists(child.xmlAttributes,"function")>
						<cfthrow type="edmund.missingAttribute" 
								message="'function' is required on 'message-listener' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#'>message-listener missing 'function' attribute in '#variables.file#'" />
					</cfif>
					<!--- multithreaded is optional and defaults to false --->
					<cfset async = false />
					<cfif structKeyExists(child.xmlAttributes,"async")>
						<cfif listFind("false,true",child.xmlAttributes.async) gt 0>
							<cfset async = child.xmlAttributes.async is "true" />
						<cfelse>
							<cfthrow type="edmund.illegalAttribute" 
									message="'multithreaded' must be 'true' or 'false'" 
									detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#'>message-listener has an async attribute of '#child.xmlAttributes.async#' which should be 'true' or 'false' in '#variables.file#'" />
						</cfif>
					</cfif>
					<!--- register the subscriber --->
					<cfset variables.edmund.register(child.xmlAttributes.message,variables.listeners[item.xmlAttributes.name],child.xmlAttributes.function,async) />
				<cfelse>
					<cfthrow type="edmund.unexpectedDeclaration" 
							message="Unexpected '#child.xmlName#' declaration found in 'message' declaration" 
							detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#'>#child.xmlName# is illegal inside a 'message' declaration in '#variables.file#'" />
				</cfif>
			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="loadEventHandlers" returntype="void" access="private" output="false" 
				hint="I load listener declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//event-handlers/event-handler") />
		<cfset var item = 0 />
		<cfset var events = 0 />
		<cfset var child = 0 />
		<cfset var broadcast = 0 />
		<cfset var result = 0 />
		<cfset var name = 0 />
		<cfset var msgId = "" />
		
		<cfloop index="item" array="#items#">
			<!--- name|event --->
			<cfif structKeyExists(item.xmlAttributes,"name")>
				<cfset name = item.xmlAttributes.name />
			<cfelseif structKeyExists(item.xmlAttributes,"event")>
				<cfset name = item.xmlAttributes.event />
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' or 'event is required on 'event-handler' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler missing 'name' or 'event' attribute in '#variables.file#'" />
			</cfif>
			<!---
				children:
					notify: listener, method
					publish: message
					broadcasts:
						children(message): name
			--->
			<cfset events = "" />
			<cfloop index="child" array="#item.xmlChildren#">
				<cfif child.xmlName is "notify">
					
					<cfif not structKeyExists(child.xmlAttributes,"listener")>
						<cfthrow type="edmund.missingAttribute" 
								message="'listener' is required on 'notify' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>notify missing 'listener' attribute in '#variables.file#'" />
					<cfelseif not structKeyExists(variables.listeners,child.xmlAttributes.listener)>
						<cfthrow type="edmund.illegalAttribute" 
								message="'#child.xmlAttributes.listener#' is an unknown listener" 
								detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>notify '#child.xmlAttributes.listener#' was not declared as a listener in '#variables.file#'" />
					</cfif>
					<cfif not structKeyExists(child.xmlAttributes,"method")>
						<cfthrow type="edmund.missingAttribute" 
								message="'method' is required on 'notify' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>notify missing 'method' attribute in '#variables.file#'" />
					</cfif>

					<!--- create unique msg id and register listener for it --->
					<cfset msgId = createUUID() />
					<cfset variables.edmund.register(msgId,variables.listeners[child.xmlAttributes.listener],child.xmlAttributes.method) />
					<!--- add unique msg id to events --->
					<cfset events = listAppend(events,msgId) />

				<cfelseif child.xmlName is "publish">

					<cfif not structKeyExists(child.xmlAttributes,"message")>
						<cfthrow type="edmund.missingAttribute" 
								message="'message' is required on 'publish' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>publish missing 'message' attribute in '#variables.file#'" />
					</cfif>

					<!--- add msg to events --->
					<cfset events = listAppend(events,child.xmlAttributes.message) />

				<cfelseif child.xmlName is "broadcasts">

					<!--- add each child to events --->
					<cfloop index="broadcast" array="#child.xmlChildren#">
					
						<cfif broadcast.xmlName is not "message">
							<cfthrow type="edmund.unexpectedDeclaration" 
									message="Unexpected '#broadcast.xmlName#' declaration found in 'broadcasts' declaration" 
									detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>broadcasts>#broadcast.xmlName# is illegal inside a 'broadcasts' declaration in '#variables.file#'" />
						</cfif>
						<cfif not structKeyExists(broadcast.xmlAttributes,"name")>
							<cfthrow type="edmund.missingAttribute" 
									message="'name' is required on 'message' declaration" 
									detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>broadcasts>message missing 'name' attribute in '#variables.file#'" />
						</cfif>
						
						<cfset events = listAppend(events,broadcast.xmlAttributes.name) />

					</cfloop>
				
				<cfelseif child.xmlName is "announce">
				
					<cfif not structKeyExists(child.xmlAttributes,"event")>
						<cfthrow type="edmund.missingAttribute" 
								message="'event' is required on 'announce' declaration" 
								detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>announce missing 'event' attribute in '#variables.file#'" />
					</cfif>

					<!--- add msg to events --->
					<cfset events = listAppend(events,"{event}#child.xmlAttributes.event#") />

				<cfelseif child.xmlName is "results">

					<!--- add each child to events --->
					<cfloop index="result" array="#child.xmlChildren#">
					
						<cfif result.xmlName is not "result">
							<cfthrow type="edmund.unexpectedDeclaration" 
									message="Unexpected '#result.xmlName#' declaration found in 'result' declaration" 
									detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>results>#result.xmlName# is illegal inside a 'results' declaration in '#variables.file#'" />
						</cfif>
						<cfif not structKeyExists(result.xmlAttributes,"do")>
							<cfthrow type="edmund.missingAttribute" 
									message="'do' is required on 'result' declaration" 
									detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler>results>result missing 'do' attribute in '#variables.file#'" />
						</cfif>
						
						<cfset events = listAppend(events,"{event}#result.xmlAttributes.do#") />

					</cfloop>

				</cfif>
			</cfloop>

			<!--- create the EventSequence listener for the event --->
			<cfset variables.edmund.register(name,createObject("component","edmund.framework.EventSequence").init(events,variables.edmund)) />

		</cfloop>

	</cffunction>

</cfcomponent>