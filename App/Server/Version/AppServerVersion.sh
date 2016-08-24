include App/Server/Version/Constants/AppServerVersionConstants.sh

AppServerVersion(){
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