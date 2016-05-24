source AppServer/AppServerConstants.sh

AppServerVersion(){

	returnAppServerVersion(){
		local appServer=$1

		AppServerConstants ${appServer}Version
	}

	$@
}   