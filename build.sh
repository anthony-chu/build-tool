source ${projectDir}lib/include.sh
source ${projectDir}lib/package.sh

include Comparator/Comparator.sh
include File/IO/Util/FileIOUtil.sh
include File/Util/FileUtil.sh
include Finder/Finder.sh
include Help/Message/HelpMessage.sh
include Message/Builder/MessageBuilder.sh

package App
package Base
package String

append="FileIOUtil append"
ASValidator="AppServerValidator"
ASVersion="AppServerVersion"
C_isEqual="Comparator isEqual"
MB="MessageBuilder"
replace="FileIOUtil replace"

_build_log(){
	local appServer=${appServer}

	local clock=$(BaseUtil timestamp clock)
	local date=$(BaseUtil timestamp date)

	logStructure=("d" "logs" "${branch}" "${appServer}" "${date}")

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

	_overrideTomcatVersion

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
	cd ${buildDir}

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}
}

_config(){
	source(){
		${MB} printProgressMessage building-properties

		local appServer=${appServer}
		local appServerDir=${bundleDir}/${appServer}-$(${ASVersion}
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

		${MB} printDone
	}

	appServer(){
		local appServer=${appServer}

		_overrideTomcatVersion

		local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

		local d=[[:digit:]]

		${MB} printProgressMessage increasing-memory-limit
		if [[ ${appServer} == tomcat ]]; then
			${replace} ${appServerDir}/bin/setenv.sh Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/setenv.sh XX:MaxPermSize=${d}\+m Xms1024m
		elif [[ ${appServer} == wildfly ]]; then
			${replace} ${appServerDir}/bin/standalone.conf Xmx${d}\+m Xmx2048m
			${replace} ${appServerDir}/bin/standalone.conf MaxMetaspaceSize=${d}\+m MaxMetaspaceSize=1024m
		fi
		${MB} printDone

		if [[ ${branch} == ee-6.2.x ]]; then
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

	for (( i=0; i<${#submodulesDir[@]}; i++ )); do
		rm -rf ${submodulesDir[i]}

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
	local database=lportal$(StringUtil replace ${branch} [-.])

	${MB} printProgressMessage rebuilding-database
	mysql -e "drop database if exists ${database};
		create database ${database} char set utf8;"
	${MB} printDone
	echo
	cd ${baseDir}
}

_overrideTomcatVersion(){
	if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
		if [[ $(StringValidator isSubstring ${branch} 6.2.x) ]]; then
			appServerVersion=7.0.62
		elif [[ $(StringValidator isSubstring ${branch} 6.1.x) ]]; then
			appServerVersion=7.0.40
		fi
	else
		appServerVersion=$(AppServerVersion returnAppServerVersion ${appServer})
	fi
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

	if [[ ${pathToModule} != "" ]]; then
		${MB} printProgressMessage deploying-module
		cd ${pathToModule}
		${buildDir}/gradlew clean deploy
		${MB} printDone
	else
		${MB} printErrorMessage a-module-with-that-name-could-not-be-found
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
	local curBranch=$(git rev-parse --abbrev-ref HEAD)

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

	_overrideTomcatVersion

	local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

	if [[ $(${ASValidator} isJboss ${appServer}) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(${ASValidator} isTomcat ${appServer}) ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(${ASValidator} isTCServer ${appServer}) ]]; then
		${appServerDir}/tc-server-3.1.3/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(${ASValidator} isWildfly ${appServer}) ]]; then
		export JAVA_HOME="C:\Program Files\Java\jdk1.8.0_71"
		${appServerDir}/bin/standalone.sh
	elif [[ $(${ASValidator} isWeblogic ${appServer}) ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	fi
}

rebuild(){
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
	appServerVersion=$(${ASVersion} returnAppServerVersion ${appServer})

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

if [[ $# == 0 ]]; then
  HelpMessage buildHelpMessage
else
	until [[ $# == 0 ]]; do
		if [[ ${1} == ${branch} ]]; then
			shift
		fi

		if [[ ${1} == ${appServer} ]]; then
			shift
		fi

		${1}

		if [[ ${1} == deploy ]]; then
			shift
		fi

		shift
	done
fi