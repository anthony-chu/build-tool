source setdir.sh
source help.sh

_build_log(){
	timestamp=$(_timestamp_clock)
	timestamp=${timestamp//[:]/}

	logStructure=("d" "logs" "${branch}" "$(_timestamp_date)")

	for (( i=0; i<${#logStructure[@]}; i++ )); do
		logDir=${logDir}/${logStructure[i]}
		if [ ! -e $logDir ]; then
			mkdir $logDir
			cd $logDir
		else
			cd $logDir
		fi
	done

	export logFile=$logDir/$branch-build-$(_gitlog)-${timestamp}.log
}

_clean_hard(){
	echo "[INFO] Deleting all files and folder in the bundles directory..."
	cd $bundleDir
	rm -rf deploy osgi data logs
	rm -rf $tomcatDir

	echo "[INFO] DONE."
	cd $baseDir
}

_clean_bundle(){
	echo "[INFO] Deleting liferay home folders..."
	cd $bundleDir
	rm -rf data logs
	echo "[INFO] DONE."
	echo

	cd $baseDir

	echo "[INFO] Deleting temp files..."
	cd $tomcatDir
	rm -rf temp work
	echo "[INFO] DONE."
	echo

	cd $baseDir
}

_clean_source(){
	cd $buildDir

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd $baseDir
}

_config(){
	source(){
		echo "[INFO] Building properties..."

		cd $buildDir/../properties
		cp *.anthonychu.properties $buildDir

		cd $buildDir
		sed -i "s/app.server.type=/app.server.type=${appServer}/g" app.server.anthonychu.properties
		sed -i "s/app.server.type=/app.server.type=${appServer}/g" build.anthonychu.properties
		echo -e "\napp.server.parent.dir=${bundleDir}" >> app.server.anthonychu.properties
		echo -e "\napp.server.parent.dir=${bundleDir}" >> build.anthonychu.properties
		echo "[INFO] Done."
	}

	appServer(){
		echo "[INFO] Increasing memory limit..."
		if [[ $appServer == tomcat ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $tomcatDir/bin/setenv.sh
			sed -i "s/-XX:MaxPermSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxPermSize=1024m/g" $tomcatDir/bin/setenv.sh
		elif [[ $appServer == wildfly ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $bundleDir/wildfly-10.0.0/bin/standalone.conf
			sed -i "s/-XX:MaxMetaspaceSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxMetaspaceSize=1024m" $bundleDir/wildfly-10.0.0/bin/standalone.conf
		fi
		echo "[INFO] Done."

		if [[ $branch == ee-6.2.x ]]; then
			echo "[INFO] Changing port for ee-6.2.x..."
			sed -i "s/\"8/\"7/g" $tomcatDir/conf/server.xml
			echo "[INFO] DONE."
		fi
	}

	$1
}

_gitlog(){
	cd $buildDir
	git log --oneline --pretty=format:%h -1
	cd $baseDir
}

_rebuild_db(){
	echo "[INFO] Rebuilding database..."
	mysql -e "drop database if exists $database; create database $database char set utf8;"
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

_timestamp_clock(){
	date +%T%s
}

_timestamp_date(){
	date +%Y%m%d
}

_validateAppServer(){
	validAppServer=(jboss-eap jonas tomcat weblogic websphere wildfly)

	for (( i=0; i<${#validAppServer[@]}; i++ )); do
		local isValidAppServer=false

		if [[ $1 == ${validAppServer[i]} ]]; then
			isValidAppServer=true
			break
		fi
	done

	echo $isValidAppServer
}

build(){
	_build_log

	_clean_hard

	_clean_source

	cd $buildDir

	if [[ $(_validateAppServer $1) == false ]]; then
		echo "$1 is not a valid app server."
		exit
	else
		appServer=$1
		shift
	fi

	_config source

	echo "[INFO] Unzipping $appServer..."
	ant -f build-dist.xml unzip-$appServer
	echo "[INFO] DONE."

	_config appServer

	echo "[INFO] Building portal..."
	echo "[INFO] Switching to JDK 7..."
	ant all > $logFile | tail -f --pid=$$ "$logFile"
	echo "[INFO] Build complete. Please see the build log for details."
	cd $baseDir
}
clean(){
	_rebuild_db
	_clean_bundle
}

pull(){
	_clean_source

	cd $buildDir

	echo "[INFO] Pulling changes from upstream..."
	git pull upstream $branch
	echo "[INFO] DONE."
	cd $baseDir
}

push(){
	cd $buildDir

	echo "[INFO] Pushing changes to origin..."
	git push -f origin $branch
	echo "[INFO] DONE."
	cd $baseDir
}

run(){
	echo "[INFO] Starting server..."
	sleep 5s
	clear

	if [[ $(_validateAppServer $1) == false ]]; then
		echo "$1 is not a valid app server."
		exit
	else
		appServer=$1
		shift
	fi

	case $appServer in
		tomcat) $tomcatDir/bin/catalina.sh run;;
		wildfly) export JAVA_HOME="C:\Program Files\Java\jdk1.8.0_71"; $bundleDir/wildfly-10.0.0/bin/standalone.sh;;
		weblogic) $bundleDir/$appServer-12.1.3/domains/liferay/bin/startWebLogic.sh;;
	esac
}

clear
getBaseDir
getDirs $@

if [[ $# == 0 ]]; then
  build_help
else
    until [[ $# == 0 ]]; do
		$1 ${@:2}
        shift
    done
fi