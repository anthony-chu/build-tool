source bash-toolbox/init.sh

include app.server.validator.AppServerValidator
include app.server.version.AppServerVersion

include base.comparator.BaseComparator
include base.vars.BaseVars

include bundle.util.BundleUtil

include command.validator.CommandValidator

include database.Database

include file.util.FileUtil
include file.writer.FileWriter

include help.message.HelpMessage

include logger.Logger

include props.writer.util.PropsWriterUtil

include string.util.StringUtil
include string.validator.StringValidator

@description rebuids_database_and_prepares_bundle_for_runtime
clean(){
	for dir in {data,logs,osgi/state}; do
		rm -rf ${nightlyDir}/${dir}
	done

	local appServerVersion=$(AppServerVersion
		getAppServerVersion ${appServer} ${branch})

	local appServerDir=${nightlyDir}/${appServer}-${appServerVersion}

	for dir in {temp,work}; do
		rm -rf ${appServerDir}/${dir}
	done

	Database rebuild ${baseDatabase}nightly utf8
}

@description downloads_a_nightly_Tomcat_bundle_on_the_indicated_branch
get(){
	cd ${buildDir}

	ant nightly

	${_log} info "completed"

	BundleUtil configure ${branch} ${appServer}

	if [[ -e ${nightlyDir} ]]; then
		${_log} info "cleaning_out_nightly_directory"

		rm -rf ${nightlyDir}/*
	else
		${_log} info "constructing_nightly_directory"

		local _nightlyDir=$(FileUtil construct ${nightlyDir})
	fi

	${_log} info "copying_${branch}_nightly_bundle_to_nightly_directory..."

	local fileDirs=(
		deploy
		license
		osgi
		${appServer}-$(AppServerVersion
			getAppServerVersion ${appServer} ${branch})
		tools
		work
		portal-ext.properties
	)

	for fileDir in ${fileDirs[@]}; do
		local _fileDir=${bundleDir}/${fileDir}

		if [[ -e ${_fileDir} || -d ${_fileDir} ]]; then
			cp -rf ${bundleDir}/${fileDir} -d ${nightlyDir}
		fi
	done

	${_log} info "updating_portal_properties"

	local props=${nightlyDir}/portal-ext.properties

	FileWriter replace ${props} ${baseDatabase} ${baseDatabase}nightly
	PropsWriterUtil setProps ${props} liferay.home $(
			FileNameUtil getPath 1 ${nightlyDir})

	${_log} info "completed"
}

@description starts_up_a_nightly_bundle
run(){
	local _appServer=$(StringUtil toUpperCase ${appServer})
	local appServerVersion=$(AppServerVersion
		getAppServerVersion ${appServer} ${branch})

	${_log} info "starting_up_a_${_appServer}_nightly_bundle"

	if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
		${nightlyDir}/${appServer}-${appServerVersion}/bin/catalina.sh run
	fi
}

main(){
	local _log="Logger log"

	@param the_app_server_\(optional\)
	local appServer=tomcat

	local baseDir=$(pwd)

	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch $@)
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	local baseDatabase=lportal${branch//[-.]/}

	local nightlyDir=${HOME}/Desktop/nightly/${branch}/bundles

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