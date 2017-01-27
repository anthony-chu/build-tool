source bash-toolbox/init.sh

include app.server.factory.AppServerFactory
include app.server.validator.AppServerValidator
include app.server.version.AppServerVersion
include app.server.version.constants.AppServerVersionConstants

include base.comparator.BaseComparator
include base.util.BaseUtil
include base.vars.BaseVars

include bundle.util.BundleUtil

include command.validator.CommandValidator

include database.Database

include file.io.util.FileIOUtil
include file.util.FileUtil

include finder.Finder

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include math.util.MathUtil

include props.writer.PropsWriter

include string.util.StringUtil
include string.validator.StringValidator

_config(){
	source(){
		Logger logProgressMsg "building_properties"

		cp ${buildDir}/../properties/*.${HOSTNAME}.properties -d ${buildDir}

		local b=${branch}

		PropsWriter setAppServerProps ${b} app.server.type ${appServer}
		PropsWriter setBuildProps ${b} app.server.type ${appServer}
		PropsWriter writeAppServerProps ${b} app.server.parent.dir=${bundleDir}
		PropsWriter writeBuildProps ${b} app.server.parent.dir=${bundleDir}
		PropsWriter writeBuildProps ${b} jsp.precompile=on

		Logger logCompletedMsg
	}

	$@
}

_generateBuildLog(){
	local appServer=${1}
	local branch=${2}
	local clock=$(BaseUtil timestamp clock)

	logDir=/d/logs/${branch}/${appServer}/$(BaseUtil timestamp date)

	FileUtil construct ${logDir}

	touch ${logDir}/${branch}-build-$(_gitlog)-${clock}.log
}

_getLogFile(){
	local appServer=${1}
	local branch=${2}

	local logDir=d:/logs/${branch}/${appServer}/$(BaseUtil timestamp date)
	local logs=($(ls ${logDir} -t))

	echo ${logDir}/${logs[0]}
}

_gitlog(){
	cd ${buildDir}
	git log --oneline --pretty=format:%h -1
}

build(){
	local appServer=${appServer}

	_generateBuildLog ${appServer} ${branch}

	BundleUtil deleteBundleContent ${branch} ${appServer}

	if [[ $(StringUtil returnOption ${1}) == c ]]; then
		doClean=true
	fi

	GitUtil cleanSource ${doClean} ${branch} ${appServer}

	cd ${buildDir}

	_config source ${appServer}

	Logger logProgressMsg "unzipping_${appServer}"
	ant -f build-dist.xml unzip-${appServer}
	Logger logCompletedMsg

	BundleUtil configure ${branch} ${appServer}

	Logger logProgressMsg "building_portal"

	logFile=$(_getLogFile ${appServer} ${branch})

	trap "Logger logCompletedMsg" SIGINT

	ant all >> ${logFile} | tail -f --pid=$$ ${logFile}
}

clean(){
	local database=lportal$(StringUtil strip branch [-.])

	Database rebuild ${database} utf8

	BundleUtil deleteHomeFolders ${branch} ${appServer}

	BundleUtil deleteTempFiles ${branch} ${appServer}
}

pull(){
	GitUtil cleanSource ${branch} ${appServer}

	cd ${buildDir}

	Logger logProgressMsg "pulling_changes_from_upstream"
	git pull upstream ${branch}
	Logger logCompletedMsg
}

push(){
	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	Logger logProgressMsg "pushing_changes_to_origin_branch_${curBranch}"

	git push -f origin ${curBranch}

	Logger logCompletedMsg
}

run(){
	local _appServer=$(StringUtil capitalize ${appServer})

	Logger logProgressMsg "starting_${branch}_Liferay_bundle_on_${_appServer}"
	sleep 5s
	clear

	appServerVersion=$(AppServerVersion
		returnAppServerVersion ${appServer} ${branch})

		local appServerDir=$(AppServerFactory
			getAppServerDir ${branch} ${appServer})

	if [[ $(${ASValidator} isJboss appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(${ASValidator} isTCServer appServer) ]]; then
		${appServerDir}/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(${ASValidator} isTomcat appServer) ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(${ASValidator} isWeblogic appServer) ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	elif [[ $(${ASValidator} isWildfly appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	fi
}

clear

args=(${@})

appServer=$(AppServerValidator returnAppServer args)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

append="FileIOUtil append"
ASValidator="AppServerValidator"
baseDir=$(pwd)
replace="FileIOUtil replace"

BaseUtil extendAntOpts ${branch}
BaseUtil setJavaHome ${branch}

if [[ $(StringValidator isNull ${1}) ]]; then
	HelpMessage buildHelpMessage
else
	until [[ $(StringValidator isNull ${1}) ]]; do
		if [[ $(BaseComparator isEqual ${1} ${appServer}) || $(
			BaseComparator isEqual ${1} ${branch}) || $(
			BaseComparator isEqual ${1} -c) ]]; then

			shift
		else
			cd ${baseDir}

			CommandValidator validateCommand ${0} ${1}

			${1}
		fi

		shift
	done
fi