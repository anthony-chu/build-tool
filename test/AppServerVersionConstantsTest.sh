include app.server.version.constants.AppServerVersionConstants
include test.executor.Testexecutor

AppServerVersionConstantsTest(){
	run(){
		local tests=(
			glassfishVersion
			jettyVersion
			jbossVersion
			jonasVersion
			resinVersion
			tcatVersion
			tcserverVersion
			tomcatVersion
			weblogicVersion
			websphereVersion
			wildflyVersion
		)

		TestExecutor executeTest AppServerVersionConstantsTest ${tests[@]}
	}

	test.glassfishVersion(){
		if [[ $(AppServerVersionConstants glassfishVersion) == 3.1.2.2 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.jbossVersion(){
		if [[ $(AppServerVersionConstants jbossVersion) == eap-6.4.0 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.jettyVersion(){
		if [[ $(AppServerVersionConstants jettyVersion) == 8.1.10 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.jonasVersion(){
		if [[ $(AppServerVersionConstants jonasVersion) == 5.2.3 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.resinVersion(){
		if [[ $(AppServerVersionConstants resinVersion) == 4.0.44 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.tcatVersion(){
		if [[ $(AppServerVersionConstants tcatVersion) == 7.0.2 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.tcserverVersion(){
		if [[ $(AppServerVersionConstants tcserverVersion) == 3.1.2 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.tomcatVersion(){
		if [[ $(AppServerVersionConstants tomcatVersion) == 8.0.32 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.weblogicVersion(){
		if [[ $(AppServerVersionConstants weblogicVersion) == 12.2.1 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.websphereVersion(){
		if [[ $(AppServerVersionConstants websphereVersion) == 8.5.5.0 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.wildflyVersion(){
		if [[ $(AppServerVersionConstants wildflyVersion) == 10.0.0 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}