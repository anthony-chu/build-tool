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
			string2=Xmx1024m

			${replace} ${appServerDir}/bin/setenv.sh ${string1} ${string2}
		elif [[ $(AppServerValidator isWildfly ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}\+m Xmx2048m

			string1=MaxMetaspaceSize=${d}\+m
			string2=MaxMetaspaceSize=1024m

			${replace} ${appServerDir}/bin/standalone.conf ${string1} ${string2}
		fi
		Logger logCompletedMsg

		if [[ $(${C_isEqual} ${branch} ee-6.2.x) ]]; then
			Logger logProgressMsg changing_port_for_${branch}
			${replace} ${appServerDir}/conf/server.xml "\"8" "\"7"
			Logger logCompletedMsg
		fi
	}

	$@
}

_disableCTCompile(){
	Logger logProgressMsg disabling_content_targeting_build_process

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

	Logger logProgressMsg rebuilding_database_${database}
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

	Logger logProgressMsg unzipping_${appServer}
	ant -f build-dist.xml unzip-${appServer}
	Logger logCompletedMsg

	_config appServer ${appServer}

	Logger logProgressMsg building_portal
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

	Logger logProgressMsg searching_for_the_desired_module

	allModules=($(Finder findByName build.gradle))

	for m in ${allModules[@]}; do
		if [[ ${m} == *${input}* ]]; then
			pathToModule=${m/build.gradle/}
			Logger logCompletedMsg
			break
		fi
	done

	if [[ $(StringValidator isNull ${pathToModule}) ]]; then
		Logger logErrorMsg a_module_with_that_name_could_not_be_found
	else
		Logger logProgressMsg deploying_module
		cd ${pathToModule}
		${buildDir}/gradlew clean deploy
		Logger logCompletedMsg
	fi

	cd ${baseDir}
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
	local appServer=${appServer}

	if [[ $(StringValidator beginsWithVowel ${appServer}) ]]; then
		n=n
	fi

	Logger logProgressMsg starting_a${n}_${branch}_Liferay_bundle_on_a${n}_${appServer}_server
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
C_isEqual="BaseComparator isEqual"
replace="FileIOUtil replace"

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