# AppServerValidator.sh

<table>
	<td colspan="12"><h3>Available Functions</h3></td>
	<tr>
		<td colspan="2"><strong>Function</strong></td>
		<td colspan="3"><strong>Parameter(s)</strong></td>
		<td colspan="3"><strong>Returns</strong></td>
		<td colspan="4"><strong>Description</strong></td>
	</tr>
	<tr>
		<td colspan="2">isGlassfish</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a GlassFish app server.</td>
	</tr>
	<tr>
		<td colspan="2">isJboss</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a JBoss app server.</td>
	</tr>
	<tr>
		<td colspan="2">isJetty</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a Jetty app server.</td>
	</tr>
	<tr>
		<td colspan="2">isJonas</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a JOnAS app server.</td>
	</tr>
	<tr>
		<td colspan="2">isResin</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a Resin app server.</td>
	</tr>
	<tr>
		<td colspan="2">isTcat</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a TCat app server.</td>
	</tr>
	<tr>
		<td colspan="2">isTCServer</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a TC Server app server.</td>
	</tr>
	<tr>
		<td colspan="2">isTomcat</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a Tomcat app server.</td>
	</tr>
	<tr>
		<td colspan="2">isWeblogic</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is an Oracle WebLogic app server.</td>
	</tr>
	<tr>
		<td colspan="2">isWebsphere</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is an IBM WebSphere app server.</td>
	</tr>
	<tr>
		<td colspan="2">isWildfly</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a WildFly app server.</td>
	</tr>
	<tr>
		<td colspan="2">returnAppServer</td>
		<td colspan="3">string</td>
		<td colspan="3">string</td>
		<td colspan="4">returns the app server if it matches a valid app server; returns Tomcat (default) app server if there are no matches</td>
	</tr>
	<tr>
		<td colspan="2">validateAppServer</td>
		<td colspan="3">string</td>
		<td colspan="3">boolean (true/false)</td>
		<td colspan="4">determines if the specified app server is a valid app server.</td>
	</tr>
</table>