source bash-toolbox/init.sh

include app.server.factory.AppServerFactory
include app.server.validator.AppServerValidator

include base.comparator.BaseComparator
include base.vars.BaseVars

include bundle.util.BundleUtil

include calendar.util.CalendarUtil

include command.validator.CommandValidator

include database.Database

include file.util.FileUtil

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include math.util.MathUtil

include props.writer.PropsWriter

include source.util.SourceUtil

include string.util.StringUtil
include string.validator.StringValidator

include system.System

_config(){
	Logger logProgressMsg "building_properties"

	local props=(app.server build)

	for prop in ${props[@]}; do
		touch ${buildDir}/${prop}.${HOSTNAME}.properties
	done

	PropsWriter setAppServerProps ${branch} app.server.parent.dir ${bundleDir}
	PropsWriter setAppServerProps ${branch} app.server.type ${appServer}

	PropsWriter setBuildProps ${branch} app.server.parent.dir ${bundleDir}
	PropsWriter setBuildProps ${branch} app.server.type ${appServer}
	PropsWriter setBuildProps ${branch} auto.deploy.dir=${bundleDir}/deploy
	PropsWriter setBuildProps ${branch} lp.source.dir ${buildDir}

	if [[ $(StringValidator isSubstring ${branch} 6.1) ]]; then
		PropsWriter setBuildProps ${branch} jsp.precompile off
	else
		PropsWriter setBuildProps ${branch} jsp.precompile on
	fi

	Logger logCompletedMsg
}

build(){
	local _logFile=(/d/logs/${branch}/${appServer}/
		$(CalendarUtil getTimestamp date)/
		${branch}-build-$(GitUtil getSHA ${buildDir} short)-
		$(CalendarUtil getTimestamp clock).log
	)

	local logFile=$(FileUtil makeFile $(StringUtil join _logFile))

	BundleUtil deleteBundleContent ${branch} ${appServer}

	if [[ $(StringUtil returnOption ${1}) == c ]]; then
		local doClean=true
	else
		local doClean=false
	fi

	GitUtil cleanSource ${doClean} ${branch}

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

	BundleUtil resetOSGiState ${branch}
}

pull(){
	if [[ $(StringUtil returnOption ${1}) == c ]]; then
		local doClean=true
	else
		local doClean=false
	fi

	GitUtil clearIndexLock ${branch}

	GitUtil cleanSource ${doClean} ${branch}

	SourceUtil clearGradleCache ${branch}

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
	PropsWriter setPortalProps ${branch} liferay.home ${bundleDir}

	local _appServer=$(StringUtil capitalize ${appServer})

	Logger logProgressMsg "starting_${branch}_Liferay_bundle_on_${_appServer}"
	sleep 5s
	clear

	local appServerDir=$(AppServerFactory
		getAppServerDir ${branch} ${appServer})

	if [[ $(AppServerValidator isJboss appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(AppServerValidator isTCServer appServer) ]]; then
		${appServerDir}/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(AppServerValidator isTomcat appServer) ]]; then
		${appServerDir}/bin/catalina.sh run
	elif [[ $(AppServerValidator isWeblogic appServer) ]]; then
		${appServerDir}/domains/liferay/bin/startWebLogic.sh
	elif [[ $(AppServerValidator isWildfly appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	fi
}

clear

args=(${@})

appServer=$(AppServerValidator returnAppServer args)
baseDir=$(pwd)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir ${branch})
bundleDir=$(BaseVars returnBundleDir ${branch})

System extendAntOpts ${branch}
System setJavaHome ${branch}

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