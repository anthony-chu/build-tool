source bash-toolbox/init.sh

include array.util.ArrayUtil
include array.validator.ArrayValidator

include base.comparator.BaseComparator
include base.vars.BaseVars

include command.validator.CommandValidator

include file.name.util.FileNameUtil
include file.util.FileUtil

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include props.writer.PropsWriter

include source.util.SourceUtil

include string.util.StringUtil
include string.validator.StringValidator

include system.System
include system.validator.SystemValidator

@private
_executeTest(){
	local testDir=$(FileUtil construct /d/test-results/${branch})

	PropsWriter setTestProps ${branch} test.skip.tear.down true
	PropsWriter setTestProps ${branch} timeout.explicit.wait 30

	local test=${1}
	shift
	Logger logProgressMsg "running_test_${test}_against_${branch}"
	echo
	cd ${buildDir}
	ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

	Logger logProgressMsg "cleaning_up_temporary_test_files"

	rm -rf ${bundleDir}/poshi/*

	Logger logCompletedMsg

	local testname=LocalFile.$(StringUtil replace test \# _)

	local resultDir=${buildDir}/portal-web/test-results/${testname}

	if [[ -d ${resultDir} ]]; then

		Logger logProgressMsg "moving_test_results"

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		local rawFile="${testDir}/${testname}/${test}_index.html"

		if [[ $(cat ${rawFile} | grep "Cause:") ]]; then
			FileUtil open "$(FileNameUtil getPath ${rawFile})"

			Logger logCompletedMsg
		else
			Logger logSuccessMsg "${test}_PASSED"
		fi
	fi
}

@description submits_a_pull_request
pr(){
	_getIssueKey(){
		cd ${buildDir}

		local gitLogOutput=($(git log --oneline --pretty=format:%s -1))

		echo ${gitLogOutput[0]}
	}

	if [[ $(StringValidator isNull ${@}) ]]; then
		Logger logErrorMsg "missing_reviewer"
	else
		Logger logProgressMsg "submitting_pull_request"

		cd ${buildDir}
		local title=$(GitUtil getCurBranch)

		local _issueKey=$(_getIssueKey)

		if [[ $(StringValidator isSubstring ${_issueKey} LPS) || $(
				StringValidator isSubstring ${_issueKey} LRQA) ]]; then

			local issueKey=${_issueKey}
		elif [[ $(StringValidator isSubstring ${title} lrqa) || $(
			StringValidator isSubstring ${title} lps) ]]; then

			local issueKey=$(StringUtil toUpperCase $(
				StringUtil strip title ${branch}- ))
		else
			Logger logErrorMsg "invalid_branch_name_and/or_commit_message"
			exit
		fi

		local detailHeading=(branch: reviewer: comment: title:)

		local detailText=(
			${branch}
			${1}
			https://issues.liferay.com/browse/${issueKey}
			${issueKey}
		)

		local newDetailHeading=($(ArrayUtil appendArrayEntry detailHeading))

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo -e "\t${newDetailHeading[i]}................ ${detailText[i]}"
		done

		echo

		git push -f origin ${title}

		local params=(
			--update-branch=${branch}
			https://issues.liferay.com/browse/${issueKey}
			${issueKey}
			-u
			${1}
		)

		GitUtil pr submit ${params[@]}

		Logger logCompletedMsg

		Logger logProgressMsg "switching_branch_to_${branch}"

		git checkout ${branch}

		Logger logCompletedMsg
	fi
}

@description formats_source_files
sf(){
	cd ${buildDir}/portal-impl

	if [[ $(BaseComparator isEqualIgnoreCase $(StringUtil
		returnOption ${1}) c) ]]; then

		local option="-current-branch"
	elif [[ $(BaseComparator isEqualIgnoreCase $(StringUtil
		returnOption ${1}) l) ]]; then

		local option="-local-changes"
	else
		local option="_all_changes"
	fi

	Logger logProgressMsg "running_source-formatter_on$(StringUtil
		replace option - _)_against_$(GitUtil getCurBranch)"

	if [[ ! $(BaseComparator isEqual ${option} _all_changes) ]]; then
		ant format-source${option}
	else
		ant format-source
	fi

	Logger logCompletedMsg
}

@description executes_a_frontend_test
test(){
	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg "missing_test_name"
	elif [[ $(StringValidator isSubstring ${1} ,) ]]; then
		local tests=${1}

		shift

		for _test in $(StringUtil split tests ,); do
			_executeTest ${_test} ${@}
		done
	else
		_executeTest ${@}
	fi
}

@description runs_poshi_validation
validate(){
	cd ${buildDir}

	local message=(
		running_
		$(StringUtil capitalize poshi)_
		validation_against_
		$(GitUtil getCurBranch)
	)

	Logger logProgressMsg "$(StringUtil join message)"

	ant -f build-test.xml run-poshi-validation $@

	Logger logCompletedMsg
}

main(){
	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch $@)
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	local args=($@)

	if [[ $@ =~ ${branch} ]]; then
		local args=($(ArrayUtil strip args ${branch}))
	fi

	if [[ $(StringValidator isNull ${args[@]}) ]]; then
		HelpMessage printHelpMessage
	elif [[ ${args[@]} == *\#* ]]; then
		test ${args[@]}
	else
		CommandValidator validateCommand ${0} ${1}

		if [[ ${args[@]} != *pr* ]]; then
			SourceUtil setupSDK ${branch}
		fi

		if [[ $(ArrayValidator hasEntry args local.release) ]]; then
			local _file=${buildDir}/modules/test/poshi-runner/settings.gradle

			rm -rf ${_file}
		fi

		${args[@]}
	fi
}

main $@