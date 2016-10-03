source ${projectDir}.init.sh

include file.name.util.FileNameUtil
include git.util.GitUtil
include help.message.HelpMessage
include logger.Logger

package array
package base
package string

pr(){
	if [[ $(StringValidator isNull ${@}) ]]; then
		Logger logErrorMsg missing_reviewer
	else
		Logger logProgressMsg submitting_pull_request

		detailHeading=(branch: reviewer: comment: title:)

		newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

		cd ${buildDir}
		title=$(GitUtil getCurBranch)
		cd ${baseDir}

		if [[ $(StringValidator isSubstring ${title} qa) ]]; then
			project=LRQA
		elif [[ $(StringValidator isSubstring ${title} lps) ]]; then
			project=LPS
		fi

		key=$(StringUtil strip ${title} [a-zA-Z\-])
		comment=https://issues.liferay.com/browse/${project}-${key}

		if [[ $# == 1 ]]; then
			branch=$(StringUtil strip ${title} -\*)
			user=${1}
		elif [[ $# == 2 ]]; then
			branch=${1}
			user=${2}
		elif [[ $# == 4 ]]; then
			user=${2}
			comment=${3}
			title=${4}
			branch=$(StringUtil strip ${title} -\*)
		fi

		detailText=("${branch}" "${user}" "${comment}" "${title}")

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo "	${newDetailHeading[i]}................${detailText[i]}"
		done

		echo
		cd ${buildDir}

		git push -f origin ${title}

		BaseUtil gitpr -b ${branch} -u ${user} submit ${comment} ${title}

		Logger logCompletedMsg

		Logger logProgressMsg switching_branch_to_${branch}

		git checkout ${branch}

		Logger logCompletedMsg

		cd ${baseDir}
	fi
}

sf(){
	if [[ $(BaseComparator isEqual ${branch} master) ]] || [[ $(StringValidator isSubstring ${branch} 7.0.x) ]]; then
		cd ${buildDir}/tools/

		sf_lib="tools/sdk/dependencies/com.liferay.source.formatter/lib"

		if [ ! -e ${buildDir}/${sf_lib} ]; then
			cd ${buildDir}

			ant setup-sdk
		fi
	fi

	implDir=${buildDir}/portal-impl

	cd ${implDir}

	opt=$(StringUtil returnOption ${1})

	if [[ $(BaseComparator isEqualIgnoreCase ${opt} a) ]]; then
		Logger logProgressMsg running_source_formatter_on_all_files
		echo
	elif [[ $(BaseComparator isEqualIgnoreCase ${opt} l) ]]; then
		localChanges="-local-changes"

		Logger logProgressMsg running_source_formatter_on$(StringUtil
			replace ${localChanges} - _)

		echo
	fi

	ant format-source${localChanges}
	Logger logCompletedMsg
	echo
	cd ${baseDir}
}

validate(){
	cd ${buildDir}

	ant -f build-test.xml run-poshi-validation $@

	cd ${baseDir}
}

test(){
	testStructure=("d" "test-results" "${branch}")

	for t in ${testStructure[@]}; do
		testDir=${testDir}/${t}
		if [ ! -e ${testDir} ]; then
			mkdir ${testDir}
			cd ${testDir}
		else
			cd ${testDir}
		fi
	done

	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg missing_test_name
	else
		test=${1}
		shift
		Logger logProgressMsg running_test_${test}
		echo
		cd ${buildDir}
		ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

		testname=$(StringUtil replace ${test} [#] _)

		resultDir=${buildDir}/portal-web/test-results/${testname}

		Logger logProgressMsg moving_test_results
		echo

		cd ${resultDir}

		cd ..

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		cd ${testDir}/${testname}
		testcase=$(StringUtil replace ${testname} [_] %23)
		chromeDir="C:/Program Files (x86)/Google/Chrome/Application"
		rawFile="${testDir}/${testname}/${testcase}_index.html"

		file="\/\/\/$(FileNameUtil getPath ${rawFile})"

		"${chromeDir}/chrome.exe" "file:${file}"

		cd ${baseDir}
	fi
}

clear
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

BaseUtil setJavaHome ${branch}

args=$@

if [[ $@ =~ ${branch} ]]; then
	args=$(ArrayUtil ${args[@]} ${branch})
fi

if [[ $(StringValidator isNull ${args}) ]]; then
	HelpMessage testHelpMessage
elif [[ ${args} == *#* ]]; then
	test ${args}
else
	${args}
fi

exit