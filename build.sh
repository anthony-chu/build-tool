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
	${_log} error "the_build_process_was_interrupted"
}

@private
_getLogFile(){
	local _logFile=(/d/logs/${branch}/${appServer}/
		$(CalendarUtil getTimestamp date)/
		${branch}-build-$(GitUtil getSHA ${branch} short)-
		$(CalendarUtil getTimestamp clock).log
	)

	FileUtil makeFile $(
		StringUtil join _logFile
	)
}

@description builds_bundle_on_specified_app_server
build(){
	@private
	_update(){
		cd ${buildDir}

		${_log} info "cleaning_source_directory..."

		FileUtil deleteIfExists ${buildDir}/modules/apps

		GitUtil cleanSource ${branch}

		if [[ $(StringValidator isSubstring branch 6.2) ]]; then
			${writer} setBuildProps ${branch} javac.compiler modern
		fi

		local baseBranch=$(StringUtil strip branch -private)

		${_log} info "fetching_${baseBranch}_portal_changes_into_${branch}..."

		git fetch --no-tags upstream ${baseBranch}

		${_log} info "completed"

		${_log} info "applying_portal_changes..."

		ant -f build-working-dir.xml |& tee -a ${logFile}

		${_log} info "completed"
	}

	local logFile=$(_getLogFile)

	if [[ $(StringValidator isSubstring ${branch} private) ]]; then
		_update
	fi

	BundleUtil deleteBundleContent ${branch} ${appServer}

	SourceUtil config ${appServer} ${branch}

	if [[ $(AppServerValidator isWebsphere appServer) ]]; then
		local zipName=agent.installer.win32.win32.x86_64_1.8.9000.20180313_1417.zip
		local zipNameProp=app.server.websphere.jdk.zip.names

		PropsWriter setAppServerProps ${branch} ${zipNameProp} ${zipName}
	fi

	${_log} info "unzipping_${appServer}..."

	cd ${buildDir}

	trap _catch SIGINT

	local _appServer=${appServer}

	if [[ $(AppServerValidator isWebsphere appServer) ]]; then
		local _appServer=${appServer}-custom
	fi

	ant -f build-dist.xml unzip-${_appServer} |& tee -a ${logFile}

	${_log} info "completed"

	${_log} info "building_portal..."

	ant all |& tee -a ${logFile}

	${_log} info "completed"

	if [[ $(AppServerValidator isTomcat appServer) ]]; then
		${_log} info "writing_git_commit_to_bottom-test.jsp..."

		ant -f build-test.xml record-git-commit-bottom-test-jsp

		${_log} info "completed"
	fi

	if [[ $(BaseComparator isEqual ${appServer} weblogic) ]]; then
		${_log} info "copying_osgi_directory_into_domain_directory..."

		local appServerDir=$(
			AppServerFactory getAppServerDir ${branch} ${appServer}
		)

		for path in {data,deploy,osgi,portal-ext.properties}; do
			cp -rf ${appServerDir}/${path} -d ${appServerDir}/domains/liferay
		done

		${_log} info "completed"
	fi

	GitUtil cleanSource ${branch}
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

	${_log} info "unzipping_${appServer}..."

	cd ${buildDir}

	trap _catch SIGINT

	ant -f build-dist.xml unzip-${appServer} |& tee -a ${logFile}

	${_log} info "deploying_portal..."

	trap _catch SIGINT

	local logFile=$(_getLogFile)

	cd ${buildDir}

	ant deploy |& tee -a ${logFile}

	${_log} info "completed"

	if [[ $(AppServerValidator isTomcat appServer) ]]; then
		${_log} info "writing_git_commit_to_bottom-test.jsp..."

		ant -f build-test.xml record-git-commit-bottom-test-jsp

		${_log} info "completed"
	fi

	GitUtil cleanSource ${branch}
}

@description pulls_changes_from_upstream_on_the_indicated_branch
pull(){
	SourceUtil clearGradleCache ${branch}

	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	if [[ ${curBranch} != ${branch} ]]; then
		${_log} info "switching_from_${curBranch}_to_${branch}..."

		git checkout -q ${branch}

		${_log} info "completed"
	fi

	if [[ $(StringValidator isSubstring branch -private) ]]; then
		FileUtil deleteIfExists ${buildDir}/modules/apps
	fi

	GitUtil cleanSource ${branch}

	${_log} info "pulling_changes_for_${branch}_from_upstream..."
	git pull upstream ${branch}
	${_log} info "completed"
}

@description pushes_changes_to_origin_on_the_indicated_branch
push(){
	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	${_log} info "pushing_changes_to_origin_branch_${curBranch}..."

	git push -f origin ${curBranch}

	${_log} info "completed"
}

@description runs_a_bundle_on_the_specified_app_server
run(){
	local _appServer=$(StringUtil capitalize ${appServer})

	${_log} info "starting_${branch}_Liferay_bundle_on_${_appServer}..."
	sleep 5s

	local appServerDir=$(
		AppServerFactory getAppServerDir ${branch} ${appServer}
	)

	if [[ $(AppServerValidator isJboss appServer) ||
			$(AppServerValidator isWildfly appServer) ]]; then

		${appServerDir}/bin/standalone.sh -b 0.0.0.0
	elif [[ $(AppServerValidator isTCServer appServer) ]]; then
		${appServerDir}/liferay/bin/tcruntime-ctl.sh liferay run
	elif [[ $(AppServerValidator isTomcat appServer) ]]; then

		${appServerDir}/bin/catalina.sh run
	elif [[ $(AppServerValidator isWeblogic appServer) ]]; then
		start ${appServerDir}/domains/liferay/bin/startWebLogic.cmd
	fi
}

@description stops_the_current_bundle_on_the_specified_app_server
stop(){
	if [[ $(AppServerValidator isTomcat appServer) ]]; then
		local stopCommand="bin/shutdown.sh"
	fi

	local appServerDir=$(
		AppServerFactory getAppServerDir ${branch} ${appServer}
	)

	${appServerDir}/${stopCommand}
}

@description zips_a_bundle_on_the_specified_app_server
zip(){
	local appServerVersion=$(
		AppServerVersion getAppServerVersion ${appServer} ${branch}
	)

	local appServerDir=${appServer}-${appServerVersion}

	${_log} info "zipping_up_a_${appServer}_bundle_for_${branch}..."

	cd ${bundleDir}

	local zipFile=liferay-portal-${appServer}-${branch}-$(
		CalendarUtil getTimestamp date)$(CalendarUtil getTimestamp clock).zip

	if [[ -e ${zipFile} ]]; then
		rm -rf ${zipFile}
	fi

	local archiveList=()
	local filepaths=(
		data deploy osgi portal-ext.properties ${appServerDir} tools work
		.liferay-home
	)

	for filepath in ${filepaths[@]}; do
		if [[ -e ${filepath} || -d ${filepath} ]]; then
			archiveList+=(${filepath})
		fi
	done

	7z a ${zipFile} ${archiveList[@]} > /dev/null

	${_log} info "completed"
}

main(){
	local _log="Logger log"

	@param the_app_server_\(optional\)
	local appServer=$(AppServerValidator returnAppServer ${@})

	local baseDir=$(pwd)

	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch $@)
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	System extendAntOpts ${branch//ee-/}
	System setJavaHome ${branch//ee/-}

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