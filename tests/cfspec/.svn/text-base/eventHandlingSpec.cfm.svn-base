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

<describe hint="Event Handling">

	<describe hint="Unhandled Event">
		
		<before>
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset edmund.addEventListener( "someEvent", listener ) />
		</before>
		
		<it should="not handle unknownEvent dispatched by name">
			<cfset edmund.dispatch( "unknownEvent" ) />
			<cfset $(listener.handled( "unknownEvent" ).handlerName).shouldBeEmpty() />
		</it>

		<it should="not handle newEvent named unknownEvent self-dispatched">
			<cfset edmund.newEvent( "unknownEvent" ).dispatch() />
			<cfset $(listener.handled( "unknownEvent" ).handlerName).shouldBeEmpty() />
		</it>

	</describe>
	
	<describe hint="Default By Name">
		
		<before>
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset edmund.addEventListener( "someEvent", listener ) />
		</before>
		
		<it should="handle someEvent dispatched by name">
			<cfset edmund.dispatch( "someEvent" ) />
			<cfset $(listener.handled( "someEvent" ).handlerName).shouldBe( "handleEvent" ) />
		</it>

		<it should="handle newEvent named someEvent self-dispatched">
			<cfset edmund.newEvent( "someEvent" ).dispatch() />
			<cfset $(listener.handled( "someEvent" ).handlerName).shouldBe( "handleEvent" ) />
		</it>

	</describe>

	<describe hint="Specific By Name">
		
		<before>
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset edmund.addEventListener( "someEvent", listener, "specificMethod" ) />
		</before>
		
		<it should="handle someEvent dispatched by name">
			<cfset edmund.dispatch( "someEvent" ) />
			<cfset $(listener.handled( "someEvent" ).handlerName).shouldBe( "specificMethod" ) />
		</it>

		<it should="handle newEvent named someEvent self-dispatched">
			<cfset edmund.newEvent( "someEvent" ).dispatch() />
			<cfset $(listener.handled( "someEvent" ).handlerName).shouldBe( "specificMethod" ) />
		</it>

	</describe>

	<describe hint="Mixed By Name">
		
		<before>
			<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset listener = createObject( "component", "edmund.tests.cfspec.cfcs.MockListener" ).init() />
			<cfset edmund.addEventListener( "defaultEvent", listener ) />
			<cfset edmund.addEventListener( "specificEvent", listener, "specificMethod" ) />
		</before>
		
		<it should="handle defaultEvent by default handler">
			<cfset edmund.dispatch( "defaultEvent" ) />
			<cfset $(listener.handled( "defaultEvent" ).handlerName).shouldBe( "handleEvent" ) />
		</it>

		<it should="handle specificEvent by specific handler">
			<cfset edmund.newEvent( "specificEvent" ).dispatch() />
			<cfset $(listener.handled( "specificEvent" ).handlerName).shouldBe( "specificMethod" ) />
		</it>

	</describe>

</describe>