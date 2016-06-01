source AppServer/AppServerValidator.sh
source AppServer/AppServerVersion.sh
source Base/BaseUtil.sh
source Base/BaseVars.sh
source Base/BaseFileIO/BaseFileIOUtil.sh
source Help/HelpMessage.sh
source Message/MessageBuilder.sh
source String/StringUtil.sh
source String/StringValidator.sh

ASValidator(){
	AppServerValidator $@
}

ASVersion(){
	AppServerVersion $@
}

MB(){
	MessageBuilder $@
}

_build_log(){
	local appServer=$(ASValidator returnAppServer ${1})

	local clock=$(BaseUtil timestamp clock)
	local date=$(BaseUtil timestamp date)

	logStructure=("d" "logs" "${branch}" "${appServer}" "${date}")

	for (( i=0; i<${#logStructure[@]}; i++ )); do
		logDir=${logDir}/${logStructure[i]}
		if [ ! -e ${logDir} ]; then
			mkdir ${logDir}
			cd ${logDir}
		else
			cd ${logDir}
		fi
	done

	export logFile=${logDir}/${branch}-build-$(_gitlog)-${clock}.log
}

_clean_hard(){
	MB printInfoMessage deleting-all-content-in-the-bundles-directory
	cd ${bundleDir}
	rm -rf deploy osgi data logs

	if [[ $(StringValidator isNull ${appServer}) == false ]]; then
		rm -rf ${appServer}*
	fi

	MB printDone
	cd ${baseDir}
}

_clean_bundle(){
	local appServer=$(ASValidator returnAppServer $@)

	if [[ ${branch} == *6.2.x* ]] && [[ ${appServer} == tomcat ]]; then
		appServerVersion=7.0.62
	else
		appServerVersion=$(ASVersion returnAppServerVersion ${appServer})
	fi

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	MB printInfoMessage deleting-liferay-home-folders
	cd ${bundleDir}
	rm -rf data logs
	MB printDone
	echo

	cd ${baseDir}

	MB printInfoMessage deleting-temp-files
	cd ${appServerDir}
	rm -rf temp work
	MB printDone
	echo

	cd ${baseDir}
}

_clean_source(){
	cd ${buildDir}

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}
}

_config(){
	local append="BaseFileIOUtil append"
	local replace="BaseFileIOUtil replace"

	source(){
		MB printInfoMessage building-properties

		local appServer=$(ASValidator returnAppServer $@)
		local appServerDir=${bundleDir}/${appServer}-$(ASVersion
			returnAppServerVersion ${appServer})

		cd ${buildDir}/../properties
		cp *.anthonychu.properties ${buildDir}

		local asProps="app.server.anthonychu.properties"
		local buildProps="build.anthonychu.properties"

		cd ${buildDir}
		${replace} ${asProps} app.server.type= app.server.type=${appServer}
		${replace} ${buildProps} app.server.type= app.server.type=${appServer}
		${append} ${asProps} "app.server.parent.dir=${bundleDir}"
		${append} ${buildProps} "app.server.parent.dir=${bundleDir}"
		${append} ${buildProps} "jsp.precompile=on"

		if [[ ${appServer} == jboss ]]; then
			echo -e "\napp.server.${appServer}.version=6.0.1" >> app.server.anthonychu.properties
		fi

		if [[ ${appServer} == tcserver ]]; then
			local asv=$(AppServerVersion returnAppServerVersion tcserver)

			echo -e "\napp.server.${appServer}.version=${asv}" >> app.server.anthonychu.properties
		fi

		MB printDone
	}

	appServer(){
		local appServer=$(ASValidator returnAppServer $@)

		if [[ ${branch} == *6.2.x* ]] && [[ ${appServer} == tomcat ]]; then
			appServerVersion=7.0.62
		else
			appServerVersion=$(ASVersion returnAppServerVersion ${appServer})
		fi

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		local d=[[:digit:]]

		MB printInfoMessage increasing-memory-limit
		if [[ ${appServer} == tomcat ]]; then
			${replace} ${appServerDir}/bin/setenv.sh Xmx${d}${d}${d}${d}m Xmx2048m
			${replace} ${appServerDir}/bin/setenv.sh MaxPermSize=${d}${d}${d}m MaxPermSize=1024m
		elif [[ ${appServer} == wildfly ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}${d}${d}${d}m Xmx2048m
			${replace} ${appServerDir}/bin/standalone.conf MaxMetaspaceSize=${d}${d}${d}m MaxMetaspaceSize=1024m
		fi
		MB printDone

		if [[ ${branch} == ee-6.2.x ]]; then
			MB printInfoMessage changing-port-for-${branch}
			${replace} ${appServerDir}/conf/server.xml "\"8" "\"7"
			MB printDone
		fi
	}

	$@
}

_gitlog(){
	cd ${buildDir}
	git log --oneline --pretty=format:%h -1
	cd ${baseDir}
}

_rebuild_db(){
	local database=lportal${branch//[-.]/""}

	MB printInfoMessage rebuilding-database
	mysql -e "drop database if exists ${database};
		create database ${database} char set utf8;"
	MB printDone
	echo
	cd ${baseDir}
}

build(){
	local appServer=$(ASValidator returnAppServer $@)

	_build_log ${appServer}

	_clean_hard ${appServer}

	_clean_source

	cd ${buildDir}

	_config source ${appServer}

	MB printInfoMessage unzipping-${appServer}
	ant -f build-dist.xml unzip-${appServer}
	MB printDone

	_config appServer ${appServer}

	MB printInfoMessage building-portal
	ant all >> ${logFile} | tail -f --pid=$$ ${logFile}
	MB printDone
}

clean(){
	_rebuild_db
	_clean_bundle
}

deploy(){
	local input=$@
	local path=$(StringUtil replace ${input} . \/)
	cd ${buildDir}/modules/apps/${path}
	${buildDir}/gradlew clean deploy
}

logger(){
	cd ${bundleDir}/logs
	tail -f liferay*.log
}

pull(){
	_clean_source

	cd ${buildDir}

	MB printInfoMessage pulling-changes-from-upstream
	git pull upstream ${branch}
	MB printDone
	cd ${baseDir}
}

push(){
	cd ${buildDir}
	local curBranch=$(git rev-parse --abbrev-ref HEAD)

	MB printInfoMessage pushing-changes-to-origin-branch-${curBranch}

	git push -f origin ${curBranch}

	MB printDone

	cd ${baseDir}
}

run(){
	local appServer=$(ASValidator returnAppServer $@)

	MB printInfoMessage starting-server
	sleep 5s
	clear

	if [[ ${branch} == *6.2.x* ]] && [[ ${appServer} == tomcat ]]; then
		appServerVersion=7.0.62
	else
		appServerVersion=$(ASVersion returnAppServerVersion ${appServer})
	fi

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	#
	# trap shutdown SIGINT

	if [[ $(ASValidator isJboss ${appServer}) == true ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(ASValidator isTomcat ${appServer}) == true ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(ASValidator isTCServer ${appServer}) == true ]]; then
		${appServerDir}/tc-server-3.1.3/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(ASValidator isWildfly ${appServer}) == true ]]; then
		export JAVA_HOME="C:\Program Files\Java\jdk1.8.0_71"
		${appServerDir}/bin/standalone.sh
	elif [[ $(ASValidator isWeblogic ${appServer}) == true ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	fi
}

shutdown(){
	local appServer=$(AppServerValidator returnAppServer ${1})
	local appServerVersion=$(AppServerVersion returnAppServerVersion ${appServer})
	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	MB printInfoMessage "Shutting down server.."

	if [[ ${appServer} == tomcat ]]; then
		${appServerDir}/bin/catalina.sh stop
	fi
}

zip(){
	cd $bundleDir

	appServer=$(ASValidator returnAppServer $@)
	appServerVersion=$(ASVersion returnAppServerVersion ${appServer})

	jar -cMf liferay-portal-${branch}.zip data deploy logs ${appServer}-${appServerVersion} osgi tools work

	cd $baseDir
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
		if [[ ${1} == ${branch} ]]; then
			shift
		fi

		${1} ${@:2}
		shift
	done
fi