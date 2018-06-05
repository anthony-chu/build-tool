source bash-toolbox/init.sh

include app.server.validator.AppServerValidator
include app.server.version.AppServerVersion

include base.comparator.BaseComparator
include base.vars.BaseVars

include command.validator.CommandValidator

include file.util.FileUtil

include help.message.HelpMessage

include logger.Logger

include string.util.StringUtil
include string.validator.StringValidator

include system.System

@description downloads_a_nightly_Tomcat_bundle_on_the_indicated_branch
get(){
	cd ${buildDir}

	ant nightly

	Logger logCompletedMsg

	if [[ -e ${nightlyDir} ]]; then
		Logger logInfoMsg cleaning_out_nightly_directory

		rm -rf ${nightlyDir}/*
	else
		Logger logInfoMsg constructing_nightly_directory

		local _nightlyDir=$(FileUtil construct ${nightlyDir})
	fi

	Logger logProgressMsg moving_nightly_bundle_to_nightly_directory

	local fileDirs=(
		data
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
		cp -rf ${bundleDir}/${fileDir} -d ${nightlyDir}
	done

	Logger logCompletedMsg
}

@description starts_up_a_nightly_bundle
run(){
	local _appServer=$(StringUtil toUpperCase ${appServer})
	local appServerVersion=$(AppServerVersion
		getAppServerVersion ${appServer} ${branch})

	Logger logInfoMsg starting_up_a_${_appServer}_nightly_bundle

	if [[ $(AppServerValidator isTomcat ${appServer}) ]]; then
		${nightlyDir}/${appServer}-${appServerVersion}/bin/catalina.sh run
	fi
}

main(){
	@param the_app_server_\(optional\)
	local appServer=$(AppServerValidator returnAppServer ${@})

	local baseDir=$(pwd)

	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch $@)
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	local nightlyDir=/d/nightly/${branch}/bundles

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