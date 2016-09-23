source ${projectDir}.init.sh

include base.comparator.BaseComparator
include git.util.GitUtil
include file.io.util.FileIOUtil
include file.util.FileUtil
include finder.Finder
include help.message.HelpMessage
include logger.Logger

package app
package base
package string

append="FileIOUtil append"
ASValidator="AppServerValidator"
ASVersion="AppServerVersion"
C_isEqual="BaseComparator isEqual"
replace="FileIOUtil replace"

_build_log(){
	local appServer=${appServer}
	local clock=$(BaseUtil timestamp clock)

	logStructure=(d logs ${branch} ${appServer} $(BaseUtil timestamp date))

	for l in ${logStructure[@]}; do
		logDir=${logDir}/${l}
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
	Logger logProgressMsg deleting-all-content-in-the-bundles-directory
	cd ${bundleDir}
	rm -rf deploy osgi data logs ${appServer}*

	Logger logCompletedMsg
	cd ${baseDir}
}

_clean_bundle(){
	local appServer=${appServer}

	appServerVersion=$(AppServerVersion
		returnAppServerVersion ${appServer} ${branch})

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	Logger logProgressMsg deleting-liferay-home-folders
	cd ${bundleDir}
	rm -rf data logs
	Logger logCompletedMsg
	echo

	cd ${baseDir}

	Logger logProgressMsg deleting-temp-files
	cd ${appServerDir}
	rm -rf temp work
	Logger logCompletedMsg
	echo

	cd ${baseDir}
}

_clean_source(){
	Logger logProgressMsg resetting-the-source-directory

	cd ${buildDir}

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}

	Logger logCompletedMsg
}

_config(){
	source(){
		Logger logProgressMsg building-properties

		local appServer=${appServer}
		local appServerDir=${bundleDir}/${appServer}-$(${ASVersion}
			returnAppServerVersion ${appServer} ${branch})

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

		Logger logCompletedMsg
	}

	appServer(){
		local appServer=${appServer}

		appServerVersion=$(AppServerVersion returnAppServerVersion ${appServer})

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		local d=[[:digit:]]

		Logger logProgressMsg increasing-memory-limit
		if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/setenv.sh Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/setenv.sh XX:MaxPermSize=${d}\+m Xms1024m
		elif [[ $(AppServerValidator isWildfly ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/standalone.conf MaxMetaspaceSize=${d}\+m MaxMetaspaceSize=1024m
		fi
		Logger logCompletedMsg

		if [[ $(${C_isEqual} ${branch} ee-6.2.x) ]]; then
			Logger logProgressMsg changing-port-for-${branch}
			${replace} ${appServerDir}/conf/server.xml "\"8" "\"7"
			Logger logCompletedMsg
		fi
	}

	$@
}

_disableCTCompile(){
	Logger logProgressMsg disabling-content-targeting-build-process

	projectDir=${buildDir}/modules/apps/content-targeting

	cd ${projectDir}

	submodulesDir=($(Finder findBySubstring lfrbuild-portal))

	for s in ${submodulesDir[@]}; do
		rm -rf ${s}

		cd ${projectDir}
	done

	cd ${baseDir}

	Logger logCompletedMsg
}

_gitlog(){
	cd ${buildDir}
	git log --oneline --pretty=format:%h -1
	cd ${baseDir}
}

_rebuild_db(){
	local database=lportal$(StringUtil strip ${branch} [-.])

	Logger logProgressMsg rebuilding-database-${database}
	mysql -e "drop database if exists ${database};
		create database ${database} char set utf8;"
	Logger logCompletedMsg
	echo
	cd ${baseDir}
}

build(){
	local appServer=${appServer}

	_build_log ${appServer}

	_clean_hard ${appServer}

	_clean_source

	if [[ $(${C_isEqual} ${branch} ee-7.0.x) ]]; then
		_disableCTCompile
	fi

	cd ${buildDir}

	_config source ${appServer}

	Logger logProgressMsg unzipping-${appServer}
	ant -f build-dist.xml unzip-${appServer}
	Logger logCompletedMsg

	_config appServer ${appServer}

	Logger logProgressMsg building-portal
	ant all >> ${logFile} | tail -f --pid=$$ ${logFile}
	Logger logCompletedMsg
}

clean(){
	_rebuild_db
	_clean_bundle
}

deploy(){
	local input=${1}

	cd ${buildDir}/modules

	echo "Module: ${input}"

	Logger logProgressMsg searching-for-the-desired-module

	allModules=($(Finder findByName build.gradle))

	for m in ${allModules[@]}; do
		if [[ ${m} == *${input}* ]]; then
			pathToModule=${m/build.gradle/}
			Logger logCompletedMsg
			break
		fi
	done

	if [[ $(StringValidator isNull ${pathToModule}) ]]; then
		Logger logErrorMsg a-module-with-that-name-could-not-be-found
	else
		Logger logProgressMsg deploying-module
		cd ${pathToModule}
		${buildDir}/gradlew clean deploy
		Logger logCompletedMsg
	fi

	cd ${baseDir}
}

pull(){
	_clean_source

	cd ${buildDir}

	Logger logProgressMsg pulling-changes-from-upstream
	git pull upstream ${branch}
	Logger logCompletedMsg
	cd ${baseDir}
}

push(){
	cd ${buildDir}
	local curBranch=$(GitUtil getCurBranch)

	Logger logProgressMsg pushing-changes-to-origin-branch-${curBranch}

	git push -f origin ${curBranch}

	Logger logCompletedMsg

	cd ${baseDir}
}

run(){
	local appServer=${appServer}

	Logger logProgressMsg starting-server
	sleep 5s
	clear

	appServerVersion=$(AppServerVersion
		returnAppServerVersion ${appServer} ${branch})

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	if [[ $(${ASValidator} isJboss ${appServer}) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(${ASValidator} isTCServer ${appServer}) ]]; then
		${appServerDir}/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(${ASValidator} isTomcat ${appServer}) ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(${ASValidator} isWeblogic ${appServer}) ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	elif [[ $(${ASValidator} isWildfly ${appServer}) ]]; then
		${appServerDir}/bin/standalone.sh
	fi
}

clear
appServer=$(AppServerValidator returnAppServer $@)
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

BaseUtil setJavaHome ${branch}

if [[ $(StringValidator isNull ${1}) ]]; then
  HelpMessage buildHelpMessage
else
	until [[ $(StringValidator isNull ${1}) ]]; do
		if [[ $(BaseComparator isEqual ${1} ${branch}) ]]; then
			shift
		fi

		if [[ $(BaseComparator isEqual ${1} ${appServer}) ]]; then
			shift
		fi

		${1}

		if [[ $(BaseComparator isEqual ${1} deploy) ]]; then
			shift
		fi

		shift
	done
fi