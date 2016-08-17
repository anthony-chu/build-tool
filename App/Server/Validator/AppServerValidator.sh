include Comparator/Comparator.sh
include String/Validator/StringValidator.sh

AppServerValidator(){
	local appServer=${2}
	local C_isEqual="Comparator isEqual"
	local SV=StringValidator

	isGlassfish(){
		if [[ $(${C_isEqual} ${appServer} glassfish) ]]; then
			echo true
		else
			return;
		fi
	}

	isJboss(){
		if [[ $(${C_isEqual} ${appServer} jboss) ]]; then
			echo true
		else
			return;
		fi
	}

	isJetty(){
		if [[ $(${C_isEqual} ${appServer} jetty) ]]; then
			echo true
		else
			return;
		fi
	}

	isJonas(){
		if [[ $(${C_isEqual} ${appServer} jonas) ]]; then
			echo true
		else
			return;
		fi
	}

	isResin(){
		if [[ $(${C_isEqual} ${appServer} resin) ]]; then
			echo true
		else
			return;
		fi
	}

	isTcat(){
		if [[ $(${C_isEqual} ${appServer} resin) ]]; then
			echo true
		else
			return;
		fi
	}

	isTCServer(){
		if [[ $(${C_isEqual} ${appServer} tcserver) ]]; then
			echo true
		else
			return;
		fi
	}

	isTomcat(){
		if [[ $(${C_isEqual} ${appServer} tomcat) ]]; then
			echo true
		else
			return;
		fi
	}

	isWeblogic(){
		if [[ $(${C_isEqual} ${appServer} weblogic) ]]; then
			echo true
		else
			return;
		fi
	}

	isWebsphere(){
		if [[ $(${C_isEqual} ${appServer} websphere) ]]; then
			echo true
		else
			return;
		fi
	}

	isWildfly(){
		if [[ $(${C_isEqual} ${appServer} wildfly) ]]; then
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
			local isValidAppServer=$(${C_isEqual} ${v} ${1})

			if [[ ${isValidAppServer} ]]; then
				break
			fi
		done

		echo ${isValidAppServer}
	}

	$@
}