source ${projectDir}App/Server/Version/Constants/AppServerVersionConstants.sh

AppServerVersion(){

	returnAppServerVersion(){
		local appServer=${1}

		AppServerVersionConstants ${appServer}Version
	}

	$@
}