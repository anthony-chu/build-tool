source ${projectDir}.init.sh

include base.comparator.BaseComparator
include git.util.GitUtil
include file.io.util.FileIOUtil
include file.util.FileUtil
include finder.Finder
include help.message.HelpMessage
include message.builder.MessageBuilder

package app
package base
package string

append="FileIOUtil append"
ASValidator="AppServerValidator"
ASVersion="AppServerVersion"
C_isEqual="BaseComparator isEqual"
MB="MessageBuilder"
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
	${MB} printProgressMessage deleting-all-content-in-the-bundles-directory
	cd ${bundleDir}
	rm -rf deploy osgi data logs ${appServer}*

	${MB} printDone
	cd ${baseDir}
}

_clean_bundle(){
	local appServer=${appServer}

	appServerVersion=$(AppServerVersion
		returnAppServerVersion ${appServer} ${branch})

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	${MB} printProgressMessage deleting-liferay-home-folders
	cd ${bundleDir}
	rm -rf data logs
	${MB} printDone
	echo

	cd ${baseDir}

	${MB} printProgressMessage deleting-temp-files
	cd ${appServerDir}
	rm -rf temp work
	${MB} printDone
	echo

	cd ${baseDir}
}

_clean_source(){
	${MB} printProgressMessage resetting-the-source-directory

	cd ${buildDir}

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}

	${MB} printDone
}

_config(){
	source(){
		${MB} printProgressMessage building-properties

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

		${MB} printDone
	}

	appServer(){
		local appServer=${appServer}

		appServerVersion=$(AppServerVersion returnAppServerVersion ${appServer})

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		local d=[[:digit:]]

		${MB} printProgressMessage increasing-memory-limit
		if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/setenv.sh Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/setenv.sh XX:MaxPermSize=${d}\+m Xms1024m
		elif [[ $(AppServerValidator isWildfly ${appServer}) ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/standalone.conf MaxMetaspaceSize=${d}\+m MaxMetaspaceSize=1024m
		fi
		${MB} printDone

		if [[ $(${C_isEqual} ${branch} ee-6.2.x) ]]; then
			${MB} printProgressMessage changing-port-for-${branch}
			${replace} ${appServerDir}/conf/server.xml "\"8" "\"7"
			${MB} printDone
		fi
	}

	$@
}

_disableCTCompile(){
	${MB} printProgressMessage disabling-content-targeting-build-process

	projectDir=${buildDir}/modules/apps/content-targeting

	cd ${projectDir}

	submodulesDir=($(Finder findBySubstring lfrbuild-portal))

	for s in ${submodulesDir[@]}; do
		rm -rf ${s}

		cd ${projectDir}
	done

	cd ${baseDir}

	${MB} printDone
}

_gitlog(){
	cd ${buildDir}
	git log --oneline --pretty=format:%h -1
	cd ${baseDir}
}

_rebuild_db(){
	local database=lportal$(StringUtil strip ${branch} [-.])

	${MB} printProgressMessage rebuilding-database-${database}
	mysql -e "drop database if exists ${database};
		create database ${database} char set utf8;"
	${MB} printDone
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

	${MB} printProgressMessage unzipping-${appServer}
	ant -f build-dist.xml unzip-${appServer}
	${MB} printDone

	_config appServer ${appServer}

	${MB} printProgressMessage building-portal
	ant all >> ${logFile} | tail -f --pid=$$ ${logFile}
	${MB} printDone
}

clean(){
	_rebuild_db
	_clean_bundle
}

deploy(){
	local input=${1}

	cd ${buildDir}/modules

	echo "Module: ${input}"

	${MB} printProgressMessage searching-for-the-desired-module

	allModules=($(Finder findByName build.gradle))

	for m in ${allModules[@]}; do
		if [[ ${m} == *${input}* ]]; then
			pathToModule=${m/build.gradle/}
			${MB} printDone
			break
		fi
	done

	if [[ $(StringValidator isNull ${pathToModule}) ]]; then
		${MB} printErrorMessage a-module-with-that-name-could-not-be-found
	else
		${MB} printProgressMessage deploying-module
		cd ${pathToModule}
		${buildDir}/gradlew clean deploy
		${MB} printDone
	fi

	cd ${baseDir}
}

logger(){
	cd ${bundleDir}/logs
	tail -f liferay*.log
}

pull(){
	_clean_source

	cd ${buildDir}

	${MB} printProgressMessage pulling-changes-from-upstream
	git pull upstream ${branch}
	${MB} printDone
	cd ${baseDir}
}

push(){
	cd ${buildDir}
	local curBranch=$(GitUtil getCurBranch)

	${MB} printProgressMessage pushing-changes-to-origin-branch-${curBranch}

	git push -f origin ${curBranch}

	${MB} printDone

	cd ${baseDir}
}

run(){
	local appServer=${appServer}

	${MB} printProgressMessage starting-server
	sleep 5s
	clear

	appServerVersion=$(AppServerVersion
		returnAppServerVersion ${appServer} ${branch})

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	if [[ $(${ASValidator} isJboss ${appServer}) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(${ASValidator} isTCServer ${appServer}) ]]; then
		${appServerDir}/tc-server-3.1.3/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(${ASValidator} isTomcat ${appServer}) ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(${ASValidator} isWeblogic ${appServer}) ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	elif [[ $(${ASValidator} isWildfly ${appServer}) ]]; then
		${appServerDir}/bin/standalone.sh
	fi
}

rebuild(){
	local appServer=${appServer}

	_build_log ${appServer}

	_clean_hard ${appServer}

	if [[ $(${C_isEqual} ${branch} ee-7.0.x) ]]; then
		_disableCTCompile
	fi

	cd ${buildDir}

	_config source ${appServer}

	${MB} printProgressMessage unzipping-${appServer}
	ant -f build-dist.xml unzip-${appServer}
	${MB} printDone

	_config appServer ${appServer}

	${MB} printProgressMessage rebuilding-portal
	ant -f build-dist.xml build-dist-${appServer} >> ${logFile} | tail -f --pid=$$ ${logFile}
	${MB} printDone
}

zip(){
	cd ${bundleDir}

	zipFile=liferay-portal-${appServer}-${branch}.zip

	if [[ $(FileUtil getStatus ${zipFile}) ]]; then
		${MB} printProgressMessage removing-old-zip-file
		rm -rf ${zipFile}
		${MB} printDone
	fi

	appServer=${appServer}
	appServerVersion=$(${ASVersion}
		returnAppServerVersion ${appServer} ${branch})

	${MB} printProgressMessage zipping-up-${appServer}-bundle

	content=(
		data
		deploy
		${appServer}-${appServerVersion}
		osgi
		tools
		work
		.liferay-home
	)

	jar -cMf ${zipFile} ${content[@]}
	${MB} printDone

	cd ${baseDir}
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