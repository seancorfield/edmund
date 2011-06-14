<!--- publish a message for the multithreaded Mach-II style subscriber --->
<cfset application.edmund.dispatch("msg1") />
<!--- publish a message for the synchronous Mach-II style subscriber --->
<cfset application.edmund.dispatch("msg2") />
<!--- broadcast a message for the asynchronous Model-Glue style listener --->
<cfset application.edmund.dispatch("msg3") />
<!--- broadcast a message for the synchronous Model-Glue style listener --->
<cfset application.edmund.dispatch("msg4") />

<!--- fire the Mach-II style event-handler --->
<cfset application.edmund.dispatch("mach") />
<!--- fire the Model-Glue style event-handler --->
<cfset application.edmund.dispatch("model") />
