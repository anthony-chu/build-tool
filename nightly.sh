#!/usr/bin/env bash

source bash-toolbox/init.sh

include app.server.version.AppServerVersion

include calendar.util.CalendarUtil

include command.validator.CommandValidator

include curl.util.CurlUtil

include file.util.FileUtil

include logger.Logger

include props.reader.util.PropsReaderUtil

include repo.Repo

get(){
	local baseUrl=$(PropsReaderUtil getValue ${snapshotProps} snapshot.url)

	cd ${bundleDir}

	${_log} info "downloading_${branch}_snapshot_bundle..."

	local url=$(echo ${baseUrl} | \
		sed "s#https\?://#http://mirrors/#g")/snapshot-${branch}/latest

	local snapshotFile=liferay-portal-${appServer}-${branch}.7z

	CurlUtil getFile ${url}/${snapshotFile}

	local appServerVersion=$(AppServerVersion
		getAppServerVersion ${appServer} ${branch})

	local appServerRelativeDir=${appServer}-${appServerVersion}

	local appServerDir=${bundleDir}/${appServerRelativeDir}

	local filePaths=(
		data
		deploy
		logs
		license
		osgi
		${appServerRelativeDir}
		tools
		work
		.githash
		.liferay-home
	)

	${_log} info "cleaning_up_bundle_files..."

	rm -rf ${filePaths[@]}

	${_log} info "extracting_${branch}_snapshot_${bundle}..."

	7z x ${snapshotFile} > /dev/null

	for filePath in ${filePaths[@]}; do
		if [[ -e liferay-portal-${branch}/${filePath} ]]; then
			mv liferay-portal-${branch}/${filePath} .
		fi
	done

	rm -rf liferay-portal-${branch} ${snapshotFile}

	${_log} info "zipping_up_${branch}_snapshot_bundle..."

	local zipFile=liferay-portal-${appServer}-${branch}-$(CalendarUtil
		getTimestamp date)$(CalendarUtil getTimestamp clock).7z

	filePaths+=(portal-ext.properties)

	FileUtil compress ${zipFile} filePaths

	${_log} info "completed."
}

main(){
	local appServer="tomcat"
	local baseDir=$(pwd)
	local branch=$(Repo getBranch $@)
	local bundleDir=$(Repo getBundleDir ${branch})

	local snapshotProps=build.snapshot.properties

	local _log="Logger log"

	until [[ ! ${1} ]]; do
		if [[ ${1} == ${appServer} || ${1} == ${branch} ]]; then
			shift
		else
			cd ${baseDir}

			CommandValidator validateCommand ${0} ${1}

			${1}
		fi

		shift
	done
}

main $@