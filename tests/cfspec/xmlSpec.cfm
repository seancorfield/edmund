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

<cfimport taglib="/cfspec" prefix="" />

<describe hint="Edmund XML's">
	
	<describe hint="Model-Glue Support">
		
		<before>
			<!--- we create the bean factory simply so we can track how the listener is used as a controller --->
			<cfset beanFactory = createObject( "component", "edmund.tests.cfspec.cfcs.SimpleBeanFactory" ) />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset beanFactory.addBean( "listener", listener ) />
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset edmund.setBeanFactory( beanFactory ) />
			<cfset edmund.loadXML('
					<model-glue>
						<controllers>
							<controller name="mock" bean="listener">
								<message-listener message="startHandled" function="startHandler" />
							</controller>
						</controllers>
						<event-handlers>
							<event-handler name="start">
								<broadcasts>
									<message name="startHandled" />
								</broadcasts>
								<results>
									<result do="next" />
								</results>
							</event-handler>
						</event-handlers>
					</model-glue>
				') />
		</before>
		
		<it should="handle start event and intercept message broadcast">
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.called("startHandler").requestName).shouldEqual( "start" ) />
		</it>
		
		<it should="handle chained event (next from start)">
			<cfset edmund.addEventListener( "next", listener ) />
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.handled("next").requestName).shouldEqual( "start" ) />
		</it>
		
		<it should="handle chained event with correct name (next from start)">
			<cfset edmund.addEventListener( "next", listener ) />
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.handled("next").name).shouldEqual( "next" ) />
		</it>
		
	</describe>
	
	<describe hint="Mach-II Support">
	
		<before>
			<!--- we create the bean factory simply so we can track how the listener is used as a controller --->
			<cfset beanFactory = createObject( "component", "edmund.tests.cfspec.cfcs.SimpleBeanFactory" ) />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset beanFactory.addBean( "listener", listener ) />
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset edmund.setBeanFactory( beanFactory ) />
			<cfset edmund.loadXML('
					<mach-ii>
						<listeners>
							<listener name="listener" bean="listener" />
						</listeners>
						<event-handlers>
							<event-handler event="start">
								<notify listener="listener" method="startHandler" /> 
								<announce event="next" />
							</event-handler>
						</event-handlers>
					</mach-ii>
				') />
		</before>
		
		<it should="handle start event and notify listener">
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.called("startHandler").requestName).shouldEqual( "start" ) />
		</it>
		
		<it should="handle chained event (next from start)">
			<cfset edmund.addEventListener( "next", listener ) />
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.handled("next").requestName).shouldEqual( "start" ) />
		</it>
		
		<it should="handle chained event with correct name (next from start)">
			<cfset edmund.addEventListener( "next", listener ) />
			<cfset edmund.dispatch( "start" ) />
			<cfset $(listener.handled("next").name).shouldEqual( "next" ) />
		</it>
		
	</describe>
	
</describe>