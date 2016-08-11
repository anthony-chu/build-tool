source ${projectDir}String/Validator/StringValidator.sh

AppServerValidator(){
	local appServer=${2}
	local SV=StringValidator

	isGlassfish(){
		if [[ $(${SV} isEqual ${appServer} glassfish) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isJboss(){
		if [[ $(${SV} isEqual ${appServer} jboss) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isJetty(){
		if [[ $(${SV} isEqual ${appServer} jetty) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isJonas(){
		if [[ $(${SV} isEqual ${appServer} jonas) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isResin(){
		if [[ $(${SV} isEqual ${appServer} resin) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isTcat(){
		if [[ $(${SV} isEqual ${appServer} resin) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isTCServer(){
		if [[ $(${SV} isEqual ${appServer} tcserver) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isTomcat(){
		if [[ $(${SV} isEqual ${appServer} tomcat) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isWeblogic(){
		if [[ $(${SV} isEqual ${appServer} weblogic) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isWebsphere(){
		if [[ $(${SV} isEqual ${appServer} websphere) == true ]]; then
			echo true
		else
			return;
		fi
	}

	isWildfly(){
		if [[ ${appServer} == wildfly ]]; then
			echo true
		else
			return;
		fi
	}

	returnAppServer(){
		if [[ $(${SV} isNull ${appServer}) == true ]]; then
			echo tomcat
		else
			if [[ $(validateAppServer ${appServer}) == true ]]; then
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

		for (( i=0; i<${#validAppServer[@]}; i++ )); do
			local isValidAppServer=$(${SV} isEqual ${validAppServer[i]} ${1})

			if [[ ${isValidAppServer} == true ]]; then
				break
			fi
		done

		echo ${isValidAppServer}
	}

	$@
}