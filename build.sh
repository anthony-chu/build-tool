source AppServer/AppServerUtil.sh
source AppServer/AppServerValidator.sh
source AppServer/AppServerVersion.sh
source Base/BaseUtil.sh
source Base/BaseVars.sh
source Help/HelpMessage.sh
source Message/MessageFactory.sh
source String/StringUtil.sh
source String/StringValidator.sh

ASValidator=AppServerValidator
ASVersion=AppServerVersion
MF=MessageFactory

_build_log(){
	local appServer=$($ASValidator returnAppServer $1)

	local clock=$(BaseUtil timestamp clock)
	local date=$(BaseUtil timestamp date)

	logStructure=("d" "logs" "${branch}" "${appServer}" "$date")

	for (( i=0; i<${#logStructure[@]}; i++ )); do
		logDir=${logDir}/${logStructure[i]}
		if [ ! -e $logDir ]; then
			mkdir $logDir
			cd $logDir
		else
			cd $logDir
		fi
	done

	export logFile=$logDir/$branch-build-$(_gitlog)-$clock.log
}

_clean_hard(){
	$MF printInfoMessage "Deleting all content in the bundles directory.."
	cd $bundleDir
	rm -rf deploy osgi data logs

	if [[ $(StringValidator isNull $appServer) == false ]]; then
		rm -rf ${appServer}*
	fi

	$MF printDone
	cd $baseDir
}

_clean_bundle(){
	local appServer=$($ASValidator returnAppServer $@)

	if [[ $branch == ee-7.0.x ]] && [[ $appServer == tomcat ]]; then
		appServerVersion=8.0.30
	elif [[ $branch == ee-6.2.x ]] && [[ $appServer == tomcat ]]; then
		appServerVersion=7.0.62
	else
		appServerVersion=$($ASVersion returnAppServerVersion ${appServer})
	fi

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	$MF printInfoMessage "Deleting liferay home folders.."
	cd $bundleDir
	rm -rf data logs
	$MF printDone
	echo

	cd $baseDir

	$MF printInfoMessage "Deleting temp files.."
	cd $appServerDir
	rm -rf temp work
	$MF printDone
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
		$MF printInfoMessage "Building properties.."

		local appServer=$($ASValidator returnAppServer $@)
		local appServerDir=${bundleDir}/${appServer}-$($ASVersion
			returnAppServerVersion ${appServer})

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

		$MF printDone
	}

	appServer(){
		local appServer=$($ASValidator returnAppServer $@)

		if [[ $branch == ee-7.0.x ]] && [[ $appServer == tomcat ]]; then
			appServerVersion=8.0.30
		elif [[ $branch == ee-6.2.x ]] && [[ $appServer == tomcat ]]; then
			appServerVersion=7.0.62
		else
			appServerVersion=$($ASVersion returnAppServerVersion ${appServer})
		fi

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		$MF printInfoMessage "Increasing memory limit.."
		if [[ $appServer == tomcat ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $appServerDir/bin/setenv.sh
			sed -i "s/-XX:MaxPermSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxPermSize=1024m/g" $appServerDir/bin/setenv.sh
		elif [[ $appServer == wildfly ]]; then
			sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $appServerDir/bin/standalone.conf
			sed -i "s/-XX:MaxMetaspaceSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxMetaspaceSize=1024m/g" $appServerDir/bin/standalone.conf
		fi
		$MF printDone

		if [[ $branch == ee-6.2.x ]]; then
			$MF printInfoMessage "Changing port for ee-6.2.x.."
			sed -i "s/\"8/\"7/g" $appServerDir/conf/server.xml
			$MF printDone
		fi
	}

	$@
}

_gitlog(){
	cd $buildDir
	git log --oneline --pretty=format:%h -1
	cd $baseDir
}

_rebuild_db(){
	local database=lportal${branch//[-.]/""}

	$MF printInfoMessage "Rebuilding database.."
	mysql -e "drop database if exists $database;
		create database $database char set utf8;"
	$MF printDone
	echo
	cd $baseDir
}

build(){
	local appServer=$($ASValidator returnAppServer $@)

	_build_log $appServer

	_clean_hard $appServer

	_clean_source

	cd $buildDir

	_config source ${appServer}

	$MF printInfoMessage "Unzipping $appServer.."
	ant -f build-dist.xml unzip-$appServer
	$MF printDone

	_config appServer ${appServer}

	$MF printInfoMessage "Building portal.."
	ant all > $logFile | tail -f --pid=$$ "$logFile"
	$MF printInfoMessage "Build complete. Please see the build log for details"
	cd $baseDir
}

clean(){
	_rebuild_db
	_clean_bundle
}

deploy(){
	local input=$@
	local path=$(StringUtil replace $input . \/)
	cd ${buildDir}/modules/apps/$path
	$buildDir/gradlew clean deploy
}

pull(){
	_clean_source

	cd $buildDir

	$MF printInfoMessage "Pulling changes from upstream.."
	git pull upstream $branch
	$MF printDone
	cd $baseDir
}

push(){
	cd $buildDir
	local branch=$(git rev-parse --abbrev-ref HEAD)

	$MF printInfoMessage "Pushing changes to origin branch ${branch}..."

	git push -f origin $branch

	cd $baseDir
}

run(){
	local appServer=$($ASValidator returnAppServer $@)

	$MF printInfoMessage "Updating database jar..."
	AppServerUtil copyDatabaseJar $appServer $branch
	$MF printDone
	echo

	$MF printInfoMessage "Starting server..."
	sleep 5s
	clear

	if [[ $branch == ee-7.0.x ]] && [[ $appServer == tomcat ]]; then
		appServerVersion=8.0.30
	elif [[ $branch == ee-6.2.x ]] && [[ $appServer == tomcat ]]; then
		appServerVersion=7.0.62
	else
		appServerVersion=$($ASVersion returnAppServerVersion ${appServer})
	fi

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	if [[ $($ASValidator isJboss $appServer) == true ]]; then
		 $appServerDir/bin/standalone.sh
	 elif [[ $($ASValidator isTomcat $appServer) == true ]]; then
		 $appServerDir/bin/catalina.sh run
	 elif [[ $($ASValidator isWildfly $appServer) == true ]]; then
		 export JAVA_HOME="C:\Program Files\Java\jdk1.8.0_71"
		 $appServerDir/bin/standalone.sh
	 elif [[ $($ASValidator isWeblogic $appServer) == true ]]; then
		 $appServerDir/domains/liferay/bin/startWebLogic.sh
	 fi
}

clear
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

if [[ $# == 0 ]]; then
  HelpMessage buildHelpMessage
else
    until [[ $# == 0 ]]; do
		if [[ $1 == ${branch} ]]; then
			shift
		fi

		$1 ${@:2}
        shift
    done
fi