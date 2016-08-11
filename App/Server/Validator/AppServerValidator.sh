source ${projectDir}String/Validator/StringValidator.sh

AppServerValidator(){
	local appServer=${2}
	local SV=StringValidator

	isGlassfish(){
		if [[ $(${SV} isEqual ${appServer} glassfish) ]]; then
			echo true
		else
			return;
		fi
	}

	isJboss(){
		if [[ $(${SV} isEqual ${appServer} jboss) ]]; then
			echo true
		else
			return;
		fi
	}

	isJetty(){
		if [[ $(${SV} isEqual ${appServer} jetty) ]]; then
			echo true
		else
			return;
		fi
	}

	isJonas(){
		if [[ $(${SV} isEqual ${appServer} jonas) ]]; then
			echo true
		else
			return;
		fi
	}

	isResin(){
		if [[ $(${SV} isEqual ${appServer} resin) ]]; then
			echo true
		else
			return;
		fi
	}

	isTcat(){
		if [[ $(${SV} isEqual ${appServer} resin) ]]; then
			echo true
		else
			return;
		fi
	}

	isTCServer(){
		if [[ $(${SV} isEqual ${appServer} tcserver) ]]; then
			echo true
		else
			return;
		fi
	}

	isTomcat(){
		if [[ $(${SV} isEqual ${appServer} tomcat) ]]; then
			echo true
		else
			return;
		fi
	}

	isWeblogic(){
		if [[ $(${SV} isEqual ${appServer} weblogic) ]]; then
			echo true
		else
			return;
		fi
	}

	isWebsphere(){
		if [[ $(${SV} isEqual ${appServer} websphere) ]]; then
			echo true
		else
			return;
		fi
	}

	isWildfly(){
		if [[ $(${SV} isEqual ${appServer} wildfly) ]]; then
			echo true
		else
			return;
		fi
	}

	returnAppServer(){
		if [[ $(${SV} isNull ${appServer}) ]]; then
			echo tomcat
		else
			if [[ $(validateAppServer ${appServer}) ]]; then
				echo ${appServer}
			else
				echo tomcat
				exit
			fi
		fi
	}

	validateAppServer(){
		validAppServer=(
			glassfish
			jetty
			jboss
			jonas
			resin
			tcat
			tcserver
			tomcat
			weblogic
			websphere
			wildfly
		)

		for v in ${validAppServer[@]}; do
			local isValidAppServer=$(${SV} isEqual ${v} ${1})

			if [[ ${isValidAppServer} ]]; then
				break
			fi
		done

		echo ${isValidAppServer}
	}

	$@
}