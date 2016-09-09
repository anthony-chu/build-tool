include App/Server/Version/Constants/AppServerVersionConstants.sh

AppServerVersion(){
	overrideTomcatVersion(){
		branch=${1}
		appServer=${2}

		if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
			if [[ $(StringValidator isSubstring ${branch} 6.2.x) ]]; then
				appServerVersion=7.0.62
			elif [[ $(StringValidator isSubstring ${branch} 6.2.10) ]]; then
				appServerVersion=7.0.42
			elif [[ $(StringValidator isSubstring ${branch} 6.1.x) ]]; then
				appServerVersion=7.0.40
			else
				appServerVersion=$(returnAppServerVersion ${appServer})
			fi
		else
			appServerVersion=$(returnAppServerVersion ${appServer})
		fi

	}

	returnAppServerVersion(){
		if [[ $# == 0 ]]; then
			return
		else
			local appServer=${1}

			AppServerVersionConstants ${appServer}Version
		fi
	}

	$@
}