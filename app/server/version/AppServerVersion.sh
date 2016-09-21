include app.server.version.constants.AppServerVersionConstants

AppServerVersion(){
	_overrideTomcatVersion(){
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
			local branch=${2}

			if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
				_overrideTomcatVersion ${branch}
			else
				AppServerVersionConstants ${appServer}Version
			fi
		fi
	}

	$@
}