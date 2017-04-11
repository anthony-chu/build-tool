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

include string.util.StringUtil
include string.validator.StringValidator

include system.System
include system.validator.SystemValidator

pr(){
	_getIssueKey(){
		cd ${buildDir}

		gitLogOutput=($(git log --oneline --pretty=format:%s -1))

		echo ${gitLogOutput[0]}
	}

	if [[ $(StringValidator isNull ${@}) ]]; then
		Logger logErrorMsg "missing_reviewer"
	else
		Logger logProgressMsg "submitting_pull_request"

		cd ${buildDir}
		title=$(GitUtil getCurBranch)

		_issueKey=$(_getIssueKey)

		if [[ $(StringValidator isSubstring ${_issueKey} LPS) || $(
				StringValidator isSubstring ${_issueKey} LRQA) ]]; then

			issueKey=${_issueKey}
		elif [[ $(StringValidator isSubstring ${title} qa) || $(StringValidator
			isSubstring ${title} lps) ]]; then

			titleArray=($(StringUtil split title -))

			if [[ $(BaseComparator isEqual ${titleArray[1]} qa) ]]; then
				_project=LRQA
			elif [[ $(BaseComparator isEqual ${titleArray[1]} lps) ]]; then
				_project=LPS
			fi

			issueKey=${_project}-$(StringUtil strip title .*-)
		else
			Logger logErrorMsg "invalid_branch_name_and/or_commit_message"
			exit
		fi

		detailHeading=(branch: reviewer: comment: title:)

		detailText=(
			${branch}
			${1}
			https://issues.liferay.com/browse/${issueKey}
			${issueKey}
		)

		newDetailHeading=($(ArrayUtil appendArrayEntry detailHeading))

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo -e "\t${newDetailHeading[i]}................${detailText[i]}"
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

sf(){
	if [[ $(BaseComparator isEqual ${branch} master) || $(StringValidator
		isSubstring ${branch} 7.0.x) ]]; then

		sf_lib="tools/sdk/dependencies/com.liferay.source.formatter/lib"

		if [ ! -e ${buildDir}/${sf_lib} ]; then
			Logger logProgressMsg "building_$(
				StringUtil toUpperCase sdk)_directory"

			cd ${buildDir}

			ant setup-sdk

			Logger logCompletedMsg
		fi
	fi

	cd ${buildDir}/portal-impl

	opt=$(StringUtil returnOption ${1})

	if [[ $(BaseComparator isEqualIgnoreCase ${opt} c) ]]; then
		option="-current-branch"
	else
		option="_all_changes"
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

test(){
	testDir=$(FileUtil construct /d/test-results/${branch})

	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg "missing_test_name"
	else
		PropsWriter setTestProps ${branch} timeout.explicit.wait 60

		test=${1}
		shift
		Logger logProgressMsg "running_test_${test}"
		echo
		cd ${buildDir}
		ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

		testname=$(StringUtil replace test \# _)

		resultDir=${buildDir}/portal-web/test-results/${testname}

		Logger logProgressMsg "moving_test_results"

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		chromeDir="C:/Program Files (x86)/Google/Chrome/Application"
		rawFile="${testDir}/${testname}/$(StringUtil
			replace testname _ %23)_index.html"

		if [[ $(SystemValidator isWindows) ]]; then
			local _env="win"
		else
			local _env="nix"
		fi

		file="\/\/\/$(FileNameUtil getPath ${_env} ${rawFile})"

		"${chromeDir}/chrome.exe" "file:${file}"

		Logger logCompletedMsg
	fi
}

validate(){
	cd ${buildDir}

	Logger logProgressMsg "running_$(StringUtil capitalize poshi)_validation"

	ant -f build-test.xml run-poshi-validation $@

	Logger logCompletedMsg
}

clear
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir ${branch})

System extendAntOpts ${branch}
System setJavaHome ${branch}

args=($@)

if [[ $@ =~ ${branch} ]]; then
	args=($(ArrayUtil strip args ${branch}))
fi

if [[ $(StringValidator isNull ${args[@]}) ]]; then
	HelpMessage testHelpMessage
elif [[ ${args[@]} == *\#* ]]; then
	test ${args[@]}
else
	CommandValidator validateCommand ${0} ${1}

	${args[@]}
fi