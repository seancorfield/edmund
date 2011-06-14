
<cfimport taglib="/cfspec" prefix="" />

<describe hint="Edmund's">

	<beforeAll>
		<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
	</beforeAll>
	
	<describe hint="Event Handler">
	
		<before>
			<cfset event = createObject( "component", "edmund.framework.Event" ) />
			<cfset eventHandler = createObject( "component", "edmund.framework.EventHandler" ) />
			<cfset logger = createObject( "component", "edmund.framework.Logger" ) />
			<cfset listener = stub( getFoo="bar" ) />
		</before>
		
		<it should="provide itself">
			<cfset logger = logger.init( "loggerA" ) />
			<cfset eventHandler = eventHandler.init( edmund, false, logger ) />
			<cfset $(eventHandler).shouldBeAnInstanceOf("edmund.framework.EventHandler") />
		</it>
		
		<it should="add a listener">
			<cfset logger = logger.init( "loggerA" ) />
			<cfset eventHandler = eventHandler.init( edmund, false, logger ) />
			<cfset eventHandler.addListener( "eventA", listener, "getFoo", false ) />
		</it>
		
		<it should="handle a common event">
			<cfset event = event.init( edmund, "eventA" ) />
			<cfset logger = logger.init( "loggerA" ) />
			<cfset eventHandler = eventHandler.init( edmund, false, logger ) />
			
			<cfset eventHandler.addListener( "eventA", listener, "getFoo", false ) />
			
			<!--- need to build a listener since we really cant use a stub --->
			<cfset eventHandler.handleEvent( "eventA", event ) />
			
		</it>
		
	</describe>

</describe>