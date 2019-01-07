source bash-toolbox/init.sh

include app.server.version.AppServerVersion

include bundle.util.BundleUtil

include calendar.util.CalendarUtil

include command.validator.CommandValidator

include database.Database

include file.name.util.FileNameUtil
include file.util.FileUtil
include file.writer.FileWriter

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include props.writer.PropsWriter
include props.writer.util.PropsWriterUtil

include repo.Repo

@description downloads_nightly_tomcat_bundle_on_indicated_branch
get(){
	cd ${buildDir}

	${_log} info "downloading_nightly_bundle..."

	if [[ ${branch} == *-private ]]; then
		if [[ ! -e build.xml ]]; then
			ant -f build-working-dir.xml
		fi
	fi

	if [[ $(Repo isPrivate ${branch}) ]]; then
		local url=https://files.liferay.com/private/ee/portal/

		PropsWriter setBuildProps ${branch} snapshot.bundle.base.url ${url}
	fi

	PropsWriter setAppServerProps ${branch} app.server.type ${APP_SERVER}
	PropsWriter setAppServerProps ${branch} app.server.version $(
		AppServerVersion getAppServerVersion ${APP_SERVER} ${branch})

	ant setup-sdk setup-libs snapshot-bundle

	if [[ ${branch} == *-private ]]; then
		GitUtil cleanSource ${branch}
	fi

	BundleUtil deleteHomeFolders ${branch}
	BundleUtil resetOSGiState ${APP_SERVER} ${branch}

	local appServerDir=${bundleDir}/${appServerRelativeDir}

	local filePaths=(
		license
		osgi
		${appServerRelativeDir}
		tools
		work
		.githash
		.liferay-home
		portal-ext.properties
	)

	${_log} info "zipping_up_nightly_bundle_for_${branch}..."

	local zipFile=liferay-portal-${APP_SERVER}-${branch}-$(
		CalendarUtil getTimestamp date)$(CalendarUtil getTimestamp clock).7z

	for filePath in ${filePaths[@]}; do
		if [[ -e ${filePath} || -d ${filePath} ]]; then
			archiveList+=(${filePath})
		fi
	done

	nullify 7z a ${zipFile} ${archiveList[@]}

	${_log} info "completed"

	Database rebuild ${nightlyDatabase} utf8
}

@description starts_up_nightly_bundle
run(){
	${_log} info "starting_up_${APP_SERVER}_nightly_bundle"
	${nightlyDir}/${appServerRelativeDir}/bin/catalina.sh run
}

main(){
	if [[ ! ${1} ]]; then
		HelpMessage printHelpMessage
	else
		local APP_SERVER=tomcat
		local branch=$(Repo getBranch $@)

		local appServerVersion=$(
			AppServerVersion getAppServerVersion ${APP_SERVER} ${branch}
		)

		local appServerRelativeDir=${APP_SERVER}-${appServerVersion}

		local baseDatabase=lportal${branch//[-.]/}
		local baseDir=$(pwd)

		local buildDir=$(Repo getBuildDir ${branch})
		local bundleDir=$(Repo getBundleDir ${branch})

		local nightlyDatabase=${baseDatabase}nightly

		local _log="Logger log"
		local replace="FileWriter replace"

		until [[ ! ${1} ]]; do
			if [[ ${1} == ${APP_SERVER} || ${1} == ${branch} ]]; then
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