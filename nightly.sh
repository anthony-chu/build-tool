source bash-toolbox/init.sh

include app.server.version.AppServerVersion

include base.comparator.BaseComparator
include base.vars.BaseVars

include command.validator.CommandValidator

include database.Database

include file.name.util.FileNameUtil
include file.util.FileUtil
include file.writer.FileWriter

include help.message.HelpMessage

include logger.Logger

include props.writer.util.PropsWriterUtil

include string.validator.StringValidator

@description downloads_nightly_tomcat_bundle_on_indicated_branch
get(){
	cd ${buildDir}

	${_log} info "downloading_nightly_bundle..."

	ant snapshot-bundle

	${_log} info "completed."

	${_log} info "renaming_tomcat_directory..."

	local bundleAppServerDir=${bundleDir}/${APP_SERVER}-${appServerVersion}

	FileUtil deleteIfExists ${bundleAppServerDir}

	mv ${bundleDir}/${APP_SERVER} ${bundleAppServerDir}

	${_log} info "completed."

	${_log} info "applying_custom_memory_settings..."

	local file=${bundleAppServerDir}/bin/setenv.sh

	${replace} ${file} 'Xmx[0-9]\+m' 'Xms1024m\\ -Xmx2048m'

	${_log} info "completed."

	if [[ -e ${nightlyDir} ]]; then
		${_log} info "cleaning_out_nightly_directory..."

		rm -rf ${nightlyDir}/*
	else
		${_log} info "constructing_nightly_directory..."

		mkdir -p ${nightlyDir}
	fi

	${_log} info "completed."

	${_log} info "copying_from_bundle_directory_to_nightly_directory..."

	local filePaths=(
		data
		deploy
		license
		logs
		osgi
		${APP_SERVER}-${appServerVersion}
		tools
		work
		.githash
		.liferay-home
		portal-ext.properties
	)

	for _filePath in ${filePaths[@]}; do
		local filePath=${bundleDir}/${_filePath}

		if [[ -e ${filePath} || -d ${filePath} ]]; then
			cp -rf ${filePath} -d ${nightlyDir}
		fi
	done

	${_log} info "completed."

	${_log} info "updating_portal_properties"

	local propsFile=${nightlyDir}/portal-ext.properties

	${replace} ${propsFile} ${baseDatabase} ${nightlyDatabase}

	local _nightlyDir=$(FileNameUtil getPath 1 ${nightlyDir})

	PropsWriterUtil setProps ${propsFile} liferay.home ${_nightlyDir}

	${_log} info "completed."

	Database rebuild ${nightlyDatabase} utf8
}

@description starts_up_nightly_bundle
run(){
	${_log} info "starting_up_${APP_SERVER}_nightly_bundle"

	${nightlyDir}/${APP_SERVER}/${appServerVersion}/catalina.sh run
}

main(){
	local APP_SERVER=tomcat
	local branch=$(BaseVars getBranch $@)

	local appServerVersion=$(
		AppServerVersion getAppServerVersion ${APP_SERVER} ${branch}
	)

	local baseDatabase=lportal${branch//[-.]/}
	local baseDir=$(pwd)

	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	local nightlyDatabase=${baseDatabase}nightly
	local nightlyDir=${HOME}/Desktop/nightly/${branch}/bundles

	local _log="Logger log"
	local replace="FileWriter replace"

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