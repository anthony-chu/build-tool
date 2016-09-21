include app.server.validator.AppServerValidator
include test.executor.TestExecutor

AppServerValidatorTest(){
	run(){
		local tests=(
			isGlassfish
			isJboss
			isJetty
			isJonas
			isResin
			isTcat
			isTCserver
			isTomcat
			isWeblogic
			isWebsphere
			isWildfly
		)

		TestExecutor executeTest AppServerValidatorTest ${tests[@]}
	}

	test.isGlassfish(){
		if [[ $(AppServerValidator isGlassfish glassfish) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isJboss(){
		if [[ $(AppServerValidator isJboss jboss) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isJetty(){
		if [[ $(AppServerValidator isJetty jetty) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isJonas(){
		if [[ $(AppServerValidator isJonas jonas) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isResin(){
		if [[ $(AppServerValidator isResin resin) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isTcat(){
		if [[ $(AppServerValidator isTcat tcat) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isTCserver(){
		if [[ $(AppServerValidator isTCServer tc-server) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isTomcat(){
		if [[ $(AppServerValidator isTomcat tomcat) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isWeblogic(){
		if [[ $(AppServerValidator isWeblogic weblogic) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isWebsphere(){
		if [[ $(AppServerValidator isWebsphere websphere) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isWildfly(){
		if [[ $(AppServerValidator isWildfly wildfly) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}