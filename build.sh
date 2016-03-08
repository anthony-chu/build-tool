source setdir.sh
source AppServer/AppServerValidator.sh
source AppServer/AppServerVersion.sh
source String/StringValidator.sh
source util.sh
source help.sh

_build_log(){
	local appServer=$1

	local timestamp=$(_timestamp_clock)
	local timestamp=${timestamp//[:]/}

	logStructure=("d" "logs" "${branch}" "${appServer}" "$(_timestamp_date)")

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
	rm -rf ${appServer}*

	echo "[INFO] DONE."
	cd $baseDir
}

_clean_bundle(){
	local appServer=$(AppServerValidator returnAppServer $@)
	local appServerDir=${bundleDir}/${appServer}-$(AppServerVersion returnAppServerVersion ${appServer})

	echo "[INFO] Deleting liferay home folders..."
	cd $bundleDir
	rm -rf data logs
	echo "[INFO] DONE."
	echo

	cd $baseDir

	echo "[INFO] Deleting temp files..."
	cd $appServerDir
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

		if [[ $appServer == jboss ]]; then
			echo -e "\napp.server.${appServer}.version=6.0.1" >> app.server.anthonychu.properties
		fi

		echo "[INFO] Done."
	}

	appServer(){
		local appServer=$(AppServerValidator returnAppServer $@)
		local appServerDir=${bundleDir}/${appServer}-$(AppServerVersion returnAppServerVersion ${appServer})

		echo "[INFO] Increasing memory limit..."
		if [[ $appServer == tomcat ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $appServerDir/bin/setenv.sh
			sed -i "s/-XX:MaxPermSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxPermSize=1024m/g" $appServerDir/bin/setenv.sh
		elif [[ $appServer == wildfly ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $appServerDir/bin/standalone.conf
			sed -i "s/-XX:MaxMetaspaceSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxMetaspaceSize=1024m/g" $appServerDir/bin/standalone.conf
		fi
		echo "[INFO] Done."

		if [[ $branch == ee-6.2.x ]]; then
			echo "[INFO] Changing port for ee-6.2.x..."
			sed -i "s/\"8/\"7/g" $appServerDir/conf/server.xml
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
	local database=lportal${branch//[-.]/""}

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

build(){
	local appServer=$(AppServerValidator returnAppServer $@)

	_build_log $appServer

	_clean_hard $appServer

	_clean_source

	cd $buildDir

	_config source

	echo "[INFO] Unzipping $appServer..."
	ant -f build-dist.xml unzip-$appServer
	echo "[INFO] DONE."

	_config appServer ${appServer}

	echo "[INFO] Building portal..."
	ant all > $logFile | tail -f --pid=$$ "$logFile"
	echo "[INFO] Build complete. Please see the build log for details."
	cd $baseDir
}

clean(){
	_rebuild_db
	_clean_bundle
}

deploy(){
	local input=$@
	local path=${input//./\/}
	cd ${buildDir}/modules/apps/$path
	$buildDir/gradlew clean deploy
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
	local branch=$(git rev-parse --abbrev-ref HEAD)

	echo "[INFO] Pushing changes to origin branch ${branch}..."

	git push -f origin $branch
	echo "[INFO] DONE."
	cd $baseDir
}

run(){
	echo "[INFO] Starting server..."
	sleep 5s
	clear

	local appServer=$(AppServerValidator returnAppServer $@)
	local appServerDir=${bundleDir}/${appServer}-$(AppServerVersion returnAppServerVersion ${appServer})

	if [[ $(AppServerValidator isJboss $appServer) == true ]]; then
		 $appServerDir/bin/standalone.sh
	 elif [[ $(AppServerValidator isTomcat $appServer) == true ]]; then
		 $appServerDir/bin/catalina.sh run
	 elif [[ $(AppServerValidator isWildfly $appServer) == true ]]; then
		 export JAVA_HOME="C:\Program Files\Java\jdk1.8.0_71"
		 $appServerDir/bin/standalone.sh
	 elif [[ $(AppServerValidator isWeblogic $appServer) == true ]]; then
		 $appServerDir/domains/liferay/bin/startWebLogic.sh
	 fi
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