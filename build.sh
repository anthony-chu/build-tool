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

include props.writer.PropsWriter

include source.util.SourceUtil

include string.util.StringUtil
include string.validator.StringValidator

include system.System

@private
_catch(){
	Logger logErrorMsg "the_build_process_was_interrupted"
}

@private
_getLogFile(){
	local _logFile=(/d/logs/${branch}/${appServer}/
		$(CalendarUtil getTimestamp date)/
		${branch}-build-$(GitUtil getSHA ${branch} short)-
		$(CalendarUtil getTimestamp clock).log
	)

	FileUtil makeFile $(StringUtil join _logFile)
}

@private
_update(){
	cd ${buildDir}

	Logger logProgressMsg "cleaning_source_directory"

	GitUtil cleanSource ${branch}

	Logger logProgressMsg "writing_properties_files"

	local writer=PropsWriter

	for props in {AppServer,Build}; do
		${writer} set${props}Props ${branch} app.server.parent.dir ${bundleDir}
		${writer} set${props}Props ${branch} app.server.type ${appServer}
	done

	Logger logCompletedMsg

	local baseBranch=$(StringUtil strip branch -private)

	Logger logProgressMsg "fetching_${baseBranch}_portal_changes_into_${branch}"

	git fetch --no-tags upstream ${baseBranch}

	Logger logCompletedMsg

	Logger logProgressMsg "applying_portal_changes"

	ant -f build-working-dir.xml

	Logger logCompletedMsg
}

@description builds_bundle_on_specified_app_server
build(){
	if [[ $(StringValidator isSubstring ${branch} private) ]]; then
		_update
	fi

	BundleUtil deleteBundleContent ${branch} ${appServer}

	SourceUtil config ${appServer} ${branch}

	Logger logProgressMsg "unzipping_${appServer}"

	local logFile=$(_getLogFile)

	cd ${buildDir}

	trap _catch SIGINT

	ant -f build-dist.xml unzip-${appServer} |& tee -a ${logFile}

	Logger logCompletedMsg

	Logger logProgressMsg "building_portal"

	ant all |& tee -a ${logFile}

	Logger logCompletedMsg

	Logger logProgressMsg "writing_git_commit_to_bottom-test.jsp"

	ant -f build-test.xml record-git-commit-bottom-test-jsp

	Logger logCompletedMsg

	if [[ $(BaseComparator isEqual ${appServer} weblogic) ]]; then
		Logger logProgressMsg "copying_osgi_directory_into_domain_directory"

		local appServerDir=$(AppServerFactory
			getAppServerDir ${branch} ${appServer})

		for path in {data,deploy,osgi,portal-ext.properties}; do
			cp -rf ${appServerDir}/${path} -d ${appServerDir}/domains/liferay
		done

		Logger logCompletedMsg
	fi
}

@description rebuilds_database_and_prepares_bundle_for_runtime
clean(){
	Database rebuild lportal$(StringUtil strip branch [-.]) utf8

	BundleUtil deleteHomeFolders ${branch} ${appServer}
	BundleUtil deleteTempFiles ${branch} ${appServer}
	BundleUtil resetOSGiState ${branch}

	PropsWriter setPortalProps ${branch} liferay.home ${bundleDir}

	if [[ ! $(StringValidator isSubstring branch 6.) ]]; then
		PropsWriter setPortalProps ${branch} virtual.hosts.default.site.name
	fi

	local propsName=module.framework.properties.blacklist.portal.profile.names
	local propsValue=(
		com.liferay.chat.service
		com.liferay.chat.web
		opensocial-portlet
	)

	PropsWriter setPortalProps ${branch} ${propsName} $(
		StringUtil join propsValue ,)
}

@description deploys_compiled_files_to_the_indicated_app_server
deploy(){
	SourceUtil config ${appServer} ${branch}

	Logger logProgressMsg "deploying_portal"

	trap _catch SIGINT

	local logFile=$(_getLogFile)

	cd ${buildDir}

	ant deploy |& tee -a ${logFile}

	Logger logCompletedMsg

	Logger logProgressMsg "writing_git_commit_to_bottom-test.jsp"

	ant -f build-test.xml record-git-commit-bottom-test-jsp

	Logger logCompletedMsg
}

@description pulls_changes_from_upstream_on_the_indicated_branch
pull(){
	SourceUtil clearGradleCache ${branch}

	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	if [[ ${curBranch} != ${branch} ]]; then
		Logger logProgressMsg "switching_from_${curBranch}_to_${branch}"

		git checkout -q ${branch}

		Logger logCompletedMsg
	fi

	GitUtil cleanSource ${branch}

	Logger logProgressMsg "pulling_changes_for_${branch}_from_upstream"
	git pull upstream ${branch}
	Logger logCompletedMsg
}

@description pushes_changes_to_origin_on_the_indicated_branch
push(){
	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	Logger logProgressMsg "pushing_changes_to_origin_branch_${curBranch}"

	git push -f origin ${curBranch}

	Logger logCompletedMsg
}

@description runs_a_bundle_on_the_specified_app_server
run(){
	local _appServer=$(StringUtil capitalize ${appServer})

	Logger logProgressMsg "starting_${branch}_Liferay_bundle_on_${_appServer}"
	sleep 5s

	local appServerDir=$(AppServerFactory
		getAppServerDir ${branch} ${appServer})

	BundleUtil configure ${branch} ${appServer}

	if [[ $(AppServerValidator isJboss appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	elif [[ $(AppServerValidator isTCServer appServer) ]]; then
		${appServerDir}/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(AppServerValidator isTomcat appServer) ]]; then

		${appServerDir}/bin/catalina.sh run
	elif [[ $(AppServerValidator isWeblogic appServer) ]]; then
		start ${appServerDir}/domains/liferay/bin/startWebLogic.cmd
	elif [[ $(AppServerValidator isWildfly appServer) ]]; then
		${appServerDir}/bin/standalone.sh
	fi
}

@description stops_the_current_bundle_on_the_specified_app_server
stop(){
	if [[ $(AppServerValidator isTomcat appServer) ]]; then
		local stopCommand="bin/shutdown.sh"
	fi

	local appServerDir=$(AppServerFactory
		getAppServerDir ${branch} ${appServer})

	${appServerDir}/${stopCommand}
}

main(){
	@param the_app_server_\(optional\)
	local appServer=$(AppServerValidator returnAppServer ${@})

	local baseDir=$(pwd)

	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch $@)
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	System extendAntOpts ${branch//ee-/}
	System setJavaHome ${branch//ee-/}

	if [[ $(StringValidator isNull ${1}) ]]; then
		HelpMessage printHelpMessage
	else
		until [[ $(StringValidator isNull ${1}) ]]; do
			if [[ $(BaseComparator isEqual ${1} ${appServer}) || $(
				BaseComparator isEqual ${1} ${branch}) ]]; then

				shift
			else
				cd ${baseDir}

				CommandValidator validateCommand ${0} ${1}

				${1}
			fi

			shift
		done
	fi
}

main $@