<cfcomponent output="false">
	
	<cffunction name="init">
		<cflog application="true" log="Application" text="init() called" type="information" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="msgSubscriber">
		<cfargument name="event" />
		<cflog application="true" log="Application" text="msgSubscriber(#arguments.event.name()#) called" type="information" />
	</cffunction>
	
	<cffunction name="msgListener">
		<cfargument name="event" />
		<cflog application="true" log="Application" text="msgListener(#arguments.event.name()#) called" type="information" />
	</cffunction>
	
	<cffunction name="directCall">
		<cfargument name="event" />
		<cflog application="true" log="Application" text="directCall(#arguments.event.name()#) called" type="information" />
	</cffunction>

</cfcomponent>