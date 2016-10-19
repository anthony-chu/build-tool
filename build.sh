source ${projectDir}.init.sh

include database.Database
include file.io.util.FileIOUtil
include file.util.FileUtil
include finder.Finder
include git.util.GitUtil
include help.message.HelpMessage
include logger.Logger

package app
package base
package string

_clean_hard(){
	Logger logProgressMsg deleting_all_content_in_the_bundles_directory
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

	Logger logProgressMsg deleting_liferay_home_folders
	cd ${bundleDir}
	rm -rf data logs
	Logger logCompletedMsg
	echo

	cd ${baseDir}

	Logger logProgressMsg deleting_temp_files
	cd ${appServerDir}
	rm -rf temp work
	Logger logCompletedMsg
	echo

	cd ${baseDir}
}

_clean_source(){
	Logger logProgressMsg resetting_the_source_directory

	cd ${buildDir}

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}

	Logger logCompletedMsg
}

_config(){
	source(){
		Logger logProgressMsg building_properties

		local appServer=${appServer}
		local appServerDir=${bundleDir}/${appServer}-$(AppServerVersion
			returnAppServerVersion ${appServer} ${branch})

		cd ${buildDir}/../properties
		cp *.anthonychu.properties ${buildDir}

		local asProps="app.server.anthonychu.properties"
		local buildProps="build.anthonychu.properties"

		cd ${buildDir}
		${replace} ${asProps} app.server.type=.* app.server.type=${appServer}
		${replace} ${buildProps} app.server.type=.* app.server.type=${appServer}
		${append} ${asProps} "app.server.parent.dir=${bundleDir}"
		${append} ${buildProps} "app.server.parent.dir=${bundleDir}"
		${append} ${buildProps} "jsp.precompile=on"

		Logger logCompletedMsg
	}

	appServer(){
		local appServer=${appServer}

		appServerVersion=$(AppServerVersion
			returnAppServerVersion ${appServer} ${branch})

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		local d=[[:digit:]]

		Logger logProgressMsg increasing_memory_limit
		if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/setenv.sh Xmx${d}\+m Xmx2048m

			string1=XX:MaxPermSize=${d}\+m
			string2=Xms1024m

			${replace} ${appServerDir}/bin/setenv.sh ${string1} ${string2}
		elif [[ $(AppServerValidator isWildfly ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}\+m Xmx2048m

			string1=MaxMetaspaceSize=${d}\+m
			string2=MaxMetaspaceSize=1024m

			${replace} ${appServerDir}/bin/standalone.conf ${string1} ${string2}
		fi
		Logger logCompletedMsg

		if [[ $(BaseComparator isEqual ${branch} ee-6.2.x) ]]; then
			Logger logProgressMsg changing_port_for_${branch}
			${replace} ${appServerDir}/conf/server.xml "\"8" "\"7"
			Logger logCompletedMsg
		fi
	}

	$@
}

_generateBuildLog(){
	local appServer=${1}
	local branch=${2}
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

	touch ${logDir}/${branch}-build-$(_gitlog)-${clock}.log
}

_getLogFile(){
	local appServer=${1}
	local branch=${2}

	local logDir=d:/logs/${branch}/${appServer}/$(BaseUtil timestamp date)

	cd ${logDir}

	local logs=($(ls -t))

	echo ${logDir}/${logs[0]}

	cd ${baseDir}
}

_gitlog(){
	cd ${buildDir}
	git log --oneline --pretty=format:%h -1
	cd ${baseDir}
}

build(){
	local appServer=${appServer}

	_generateBuildLog ${appServer} ${branch}

	_clean_hard ${appServer}

	_clean_source

	cd ${buildDir}

	_config source ${appServer}

	Logger logProgressMsg unzipping_${appServer}
	ant -f build-dist.xml unzip-${appServer}
	Logger logCompletedMsg

	_config appServer ${appServer}

	Logger logProgressMsg building_portal

	logFile=$(_getLogFile ${appServer} ${branch})

	ant all >> ${logFile} | tail -f --pid=$$ ${logFile}
	Logger logCompletedMsg
}

clean(){
	local database=lportal$(StringUtil strip ${branch} [-.])

	Logger logProgressMsg rebuilding_database_${database}

	Database rebuild ${database} utf8

	Logger logCompletedMsg

	_clean_bundle
}

pull(){
	_clean_source

	cd ${buildDir}

	Logger logProgressMsg pulling_changes_from_upstream
	git pull upstream ${branch}
	Logger logCompletedMsg
	cd ${baseDir}
}

push(){
	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	Logger logProgressMsg pushing_changes_to_origin_branch_${curBranch}

	git push -f origin ${curBranch}

	Logger logCompletedMsg

	cd ${baseDir}
}

run(){
	local appServer=$(StringUtil capitalize ${appServer})

	Logger logProgressMsg starting_${branch}_Liferay_bundle_on_${appServer}_server
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

append="FileIOUtil append"
ASValidator="AppServerValidator"
replace="FileIOUtil replace"

BaseUtil extendAntOpts ${branch}
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