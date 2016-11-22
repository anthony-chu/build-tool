source bash-toolbox/init.sh

include array.util.ArrayUtil
include array.validator.ArrayValidator
include base.comparator.BaseComparator
include base.util.BaseUtil
include base.vars.BaseVars
include file.name.util.FileNameUtil
include file.util.FileUtil
include git.util.GitUtil
include help.message.HelpMessage
include logger.Logger
include string.util.StringUtil
include string.validator.StringValidator

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

		detailHeading=(branch: reviewer: comment: title:)

		newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

		cd ${buildDir}
		title=$(GitUtil getCurBranch)

		_issueKey=$(_getIssueKey)

		if [[ $(StringValidator isSubstring ${title} qa) || $(StringValidator
			isSubstring ${title} lps) ]]; then

			titleArray=($(StringUtil replace ${title} - space))

			if [[ $(BaseComparator isEqual ${titleArray[1]} qa) ]]; then
				_project=LRQA
			elif [[ $(BaseComparator isEqual ${titleArray[1]} lps) ]]; then
				_project=LPS
			fi

			issueKey=${_project}-$(StringUtil strip ${title} *-)
		elif [[ $(StringValidator isSubstring $(_getIssueKey) LPS) || $(
				StringValidator isSubstring $(_getIssueKey) LRQA) ]]; then

			issueKey=$(_getIssueKey)
		else
			Logger logErrorMsg "invalid_branch_name_and/or_commit_message"
			exit
		fi

		comment=https://issues.liferay.com/browse/${issueKey}

		user=${1}

		detailText=("${branch}" "${user}" "${comment}" "${title}")

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo -e "\t${newDetailHeading[i]}................${detailText[i]}"
		done

		echo

		git push -f origin ${title}

		BaseUtil gitpr -b ${branch} -u ${user} submit ${comment} ${title}

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
			cd ${buildDir}

			ant setup-sdk
		fi
	fi

	cd ${buildDir}/portal-impl

	opt=$(StringUtil returnOption ${1})

	if [[ $(BaseComparator isEqualIgnoreCase ${opt} a) ]]; then
		Logger logProgressMsg "running_source_formatter_on_all_files"
		echo
	elif [[ $(BaseComparator isEqualIgnoreCase ${opt} l) ]]; then
		localChanges="-local-changes"

		Logger logProgressMsg "running_source_formatter_on$(StringUtil
			replace ${localChanges} - _)"

		echo
	fi

	ant format-source${localChanges}
	Logger logCompletedMsg
}

validate(){
	cd ${buildDir}

	ant -f build-test.xml run-poshi-validation $@
}

test(){
	testDir=/d/test-results/${branch}

	FileUtil construct ${testDir}

	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg "missing_test_name"
	else
		test=${1}
		shift
		Logger logProgressMsg "running_test_${test}"
		echo
		cd ${buildDir}
		ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

		testname=$(StringUtil replace ${test} [\#] _)

		resultDir=${buildDir}/portal-web/test-results/${testname}

		Logger logProgressMsg "moving_test_results"

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		cd ${testDir}/${testname}
		testcase=$(StringUtil replace ${testname} [_] %23)
		chromeDir="C:/Program Files (x86)/Google/Chrome/Application"
		rawFile="${testDir}/${testname}/${testcase}_index.html"

		file="\/\/\/$(FileNameUtil getPath ${rawFile})"

		"${chromeDir}/chrome.exe" "file:${file}"

		Logger logCompletedMsg
	fi
}

clear
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

BaseUtil extendAntOpts ${branch}
BaseUtil setJavaHome ${branch}

args=$@

if [[ $@ =~ ${branch} ]]; then
	args=$(ArrayUtil strip ${args} ${branch})
fi

if [[ $(StringValidator isNull ${args}) ]]; then
	HelpMessage testHelpMessage
elif [[ ${args} == *\#* ]]; then
	test ${args}
else
	${args}
fi