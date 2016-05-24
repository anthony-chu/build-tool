source AppServer/AppServerConstants.sh

AppServerVersion(){
	_glassfishVersion(){
		AppServerConstants glassfishVersion
	}

	_jettyVersion(){
		AppServerConstants jettyVersion
	}

	_jbossVersion(){
		AppServerConstants jbossVersion
	}

	_jonasVersion(){
		AppServerConstants jonasVersion
	}

	_resinVersion(){
		AppServerConstants resinVersion
	}

	_tcatVersion(){
		AppServerConstants tcatVersion
	}

	_tcserverVersion(){
		AppServerConstants tcserverVersion
	}

	_tomcatVersion(){
		AppServerConstants tomcatVersion
	}

	_weblogicVersion(){
		AppServerConstants weblogicVersion
	}

	_websphereVersion(){
		AppServerConstants websphereVersion
	}

	_wildflyVersion(){
		AppServerConstants wildflyVersion
	}

	returnAppServerVersion(){
		local appServer=$1

		echo $(_${appServer}Version)
	}

	$@
}   