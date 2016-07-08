source ${projectDir}String/Validator/StringValidator.sh

AppServerValidator(){
	local appServer=${2}
	local SV=StringValidator

	isGlassfish(){
		if [[ $(${SV} isEqual ${appServer} glassfish) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isJboss(){
		if [[ $(${SV} isEqual ${appServer} jboss) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isJetty(){
		if [[ $(${SV} isEqual ${appServer} jetty) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isJonas(){
		if [[ $(${SV} isEqual ${appServer} jonas) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isResin(){
		if [[ $(${SV} isEqual ${appServer} resin) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isTcat(){
		if [[ $(${SV} isEqual ${appServer} resin) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isTCServer(){
		if [[ $(${SV} isEqual ${appServer} tcserver) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isTomcat(){
		if [[ $(${SV} isEqual ${appServer} tomcat) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isWeblogic(){
		if [[ $(${SV} isEqual ${appServer} weblogic) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isWebsphere(){
		if [[ $(${SV} isEqual ${appServer} websphere) == true ]]; then
			echo true
		else
			echo false
		fi
	}

	isWildfly(){
		if [[ ${appServer} == wildfly ]]; then
			echo true
		else
			echo false
		fi
	}

	returnAppServer(){
		if [[ $(${SV} isNull ${appServer}) == true ]]; then
			echo "tomcat"
		else
			if [[ $(validateAppServer ${appServer}) == true ]]; then
				echo ${appServer}
			else
				echo null
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