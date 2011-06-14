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

<describe hint="Edmund Event's">

	<before>
		<cfset event = createObject( "component", "edmund.framework.Event" ) />
	</before>
	
	<describe hint="base object">
		
		<it should="be unnamed (because Edmund did not create it)">
			<cfset $(event).name().shouldEqual( "[unnamed event]" ) />
			<cfset $(event).requestName().shouldEqual( "[unnamed event]" ) />
		</it>

		<it should="have no values">
			<cfset $(event).all().shouldBeEmpty() />
		</it>
		
		<it should="not bubble events">
			<cfset $(event).bubble().shouldBeFalse() />
		</it>
		
	</describe>

	<describe hint="value">
		
		<it should="return an event instance">
			<cfset $(event).value("foo","bar").shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>

		<it should="set and get a value">
			<cfset event.value("foo", "bar") />
			<cfset $(event).value("foo").shouldEqual( "bar" ) />
		</it>
		
		<it should="have a value after being set">
			<cfset event.value("foo", "bar") />
			<cfset $(event).has("foo").shouldBeTrue() />
		</it>
		
		<it should="not have a value that has not set">
			<cfset $(event).has("unknown").shouldBeFalse() />
		</it>
		
		<it should="throw an exception for an unknown value">
			<cfset $(event).value("unknown").shouldThrow( "expression",
				"Element unknown is undefined in a CFML structure referenced as part of an expression." ) />
		</it>

	</describe>
	
	<describe hint="has">

		<it should="be true for a value that is set">
			<cfset event.value("foo", "bar") />
			<cfset $(event).has("foo").shouldBeTrue() />
		</it>
		
		<it should="be false for a value that has not set">
			<cfset $(event).has("unknown").shouldBeFalse() />
		</it>

	</describe>
	
	<describe hint="values">

		<it should="return an event instance">
			<cfset $(event).values( foo="bar" ).shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>

		<it should="set multiple values">
			<cfset event.values( foo1="bar1", foo2="bar2" ) />
			<cfset $(event).value("foo1").shouldEqual("bar1") />	
			<cfset $(event).value("foo2").shouldEqual("bar2") />	
		</it>

	</describe>
	
	<describe hint="all">
	
		<it should="contain all values set">
			<cfset event.values( foo1="bar1", foo2="bar2" ) />
			<cfset $(event).all().shouldContain( "foo1", "foo2" ) />
		</it>
		
		<it should="be a shallow copy of values">
			<cfset complex = { a=1, b=2 } />
			<cfset event.values( simple="simple", complex=complex ) />
			<cfset all = event.all() />
			<cfset $(all["simple"]).shouldBeSimpleValue() />
			<cfset $(all["simple"]).shouldEqual( "simple" ) />
			<cfset $(all["complex"]).shouldNotBeSimpleValue() />
			<cfset $(all["complex"]).shouldBe( complex ) />
		</it>
		
	</describe>
	
	<describe hint="bubble">
	
		<it should="return an event instance">
			<cfset $(event).bubble(true).shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>

		<it should="change the bubbling status">
			<cfset $(event).bubble(true).bubble().shouldBeTrue() />
			<cfset $(event).bubble(false).bubble().shouldBeFalse() />
		</it>
	
	</describe>
	
	<describe hint="name">
		
		<it should="return an event instance">
			<cfset $(event).name("event").shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>

		<it should="set and return the event name">
			<cfset $(event).name("namedEvent").name().shouldEqual( "namedEvent" ) />
		</it>

		<it should="set also set the event request name">
			<cfset $(event).name("namedEvent").requestName().shouldEqual( "namedEvent" ) />
		</it>

	</describe>

	<describe hint="request name">
		
		<it should="return an event instance">
			<cfset $(event).requestName("request").shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>

		<it should="set and return the event request name">
			<cfset $(event).requestName("namedRequest").requestName().shouldEqual( "namedRequest" ) />
		</it>

		<it should="not change the event name">
			<cfset $(event).name("namedEvent").requestName("namedRequest").name().shouldEqual( "namedEvent" ) />
		</it>

	</describe>

</describe>