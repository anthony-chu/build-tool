source AppServer/Version/AppServerVersionConstants.sh

AppServerVersion(){

	returnAppServerVersion(){
		local appServer=${1}

		AppServerVersionConstants ${appServer}Version
	}

	$@
}