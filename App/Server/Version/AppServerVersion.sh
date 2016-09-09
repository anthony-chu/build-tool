include App/Server/Version/Constants/AppServerVersionConstants.sh

AppServerVersion(){
	overrideTomcatVersion(){
		branch=${1}

		if [[ $(StringValidator isSubstring ${branch} 6.2.x) ]]; then
			echo 7.0.62
		elif [[ $(StringValidator isSubstring ${branch} 6.2.10) ]]; then
			echo 7.0.42
		elif [[ $(StringValidator isSubstring ${branch} 6.1.x) ]]; then
			echo 7.0.40
		else
			AppServerVersionConstants tomcatVersion
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