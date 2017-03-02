source bash-toolbox/init.sh

include bundle.util.BundleUtil

include command.validator.CommandValidator

include database.Database

include file.io.util.FileIOUtil
include file.util.FileUtil

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include math.util.MathUtil

include props.writer.PropsWriter

include string.util.StringUtil
include string.validator.StringValidator

package app.server
package base

_config(){
	Logger logProgressMsg "building_properties"

	local props=(app.server build)

	for prop in ${props[@]}; do
		touch ${buildDir}/${prop}.${HOSTNAME}.properties
	done

	local b=${branch}

	PropsWriter setAppServerProps ${b} app.server.parent.dir ${bundleDir}
	PropsWriter setAppServerProps ${b} app.server.type ${appServer}

	PropsWriter setBuildProps ${b} app.server.parent.dir ${bundleDir}
	PropsWriter setBuildProps ${b} app.server.type ${appServer}
	PropsWriter setBuildProps ${b} auto.deploy.dir=${bundleDir}/deploy
	PropsWriter setBuildProps ${b} lp.source.dir ${buildDir}
	PropsWriter setBuildProps ${b} jsp.precompile on

	Logger logCompletedMsg
}

build(){
	local _logFile=(/d/logs/${branch}/${appServer}/
		$(BaseUtil timestamp date)/
		${branch}-build-$(GitUtil getSHA ${buildDir} short)-
		$(BaseUtil timestamp clock).log
	)

	local logFile=$(FileUtil makeFile $(StringUtil join _logFile))

	BundleUtil deleteBundleContent ${branch} ${appServer}

	if [[ $(StringUtil returnOption ${1}) == c ]]; then
		local doClean=true
	else
		local doClean=false
	fi

	GitUtil cleanSource ${doClean} ${branch}

	cd ${buildDir}

	_config ${appServer}

	Logger logProgressMsg "unzipping_${appServer}"
	ant -f build-dist.xml unzip-${appServer}
	Logger logCompletedMsg

	BundleUtil configure ${branch} ${appServer}

	Logger logProgressMsg "building_portal"

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
	if [[ $(StringUtil returnOption ${1}) == c ]]; then
		local doClean=true
	else
		local doClean=false
	fi

	GitUtil clearIndexLock ${branch}

	GitUtil cleanSource ${doClean} ${branch}

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