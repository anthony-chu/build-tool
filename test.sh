source ${projectDir}.init.sh

include comparator/Comparator.sh
include file/name/util/FileNameUtil.sh
include git/util/GitUtil.sh
include help/message/HelpMessage.sh
include message/builder/MessageBuilder.sh

package array
package base
package string

MB=MessageBuilder

mockmock(){
	cd ${buildDir}

	${MB} printProgressMessage building-MockMock-jar

	ant -f build-test.xml start-test-smtp-server

	clear

	${MB} printProgressMessage starting-MockMock-SMTP-server

	sleep 5s

	clear

	cd lib/development

	java -jar MockMock.jar
}

pr(){
	if [[ $(StringValidator isNull ${@}) ]]; then
		${MB} printErrorMessage missing-reviewer
	else
		${MB} printProgressMessage submitting-pull-request

		detailHeading=(branch: reviewer: comment: title:)

		newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

		cd ${buildDir}
		title=$(GitUtil getCurBranch)
		cd ${baseDir}

		branchArray=($(StringUtil replace ${title} - space))

		if [[ $(ArrayValidator hasEntry ${branchArray[@]} qa) ]]; then
			project=LRQA
		elif [[ $(ArrayValidator hasEntry ${branchArray[@]} lps) ]]; then
			project=LPS
		fi

		key=${branchArray[-1]}
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

		${MB} printDone

		${MB} printProgressMessage switching-branch-to-${branch}

		git checkout ${branch}

		${MB} printDone

		cd ${baseDir}
	fi
}

sf(){
	if [[ $(Comparator isEqual ${branch} master) ]] || [[ $(StringValidator isSubstring ${branch} 7.0.x) ]]; then
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

	if [[ $(Comparator isEqualIgnoreCase ${opt} a) ]]; then
		${MB} printProgressMessage running-source-formatter-on-all-files
		echo
	elif [[ $(Comparator isEqualIgnoreCase ${opt} l) ]]; then
		localChanges="-local-changes"

		${MB} printProgressMessage running-source-formatter-on${localChanges}
		echo
	fi

	ant format-source${localChanges}
	${MB} printDone
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
		${MB} printErrorMessage missing-test-name
	else
		test=${1}
		shift
		${MB} printProgressMessage running-test-${test}
		echo
		cd ${buildDir}
		ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

		testname=$(StringUtil replace ${test} [#] _)

		resultDir=${buildDir}/portal-web/test-results/${testname}

		${MB} printProgressMessage moving-test-results
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
	args=$(StringUtil strip ${@} ${branch})
fi

if [[ $(StringValidator isNull ${args}) ]]; then
	HelpMessage testHelpMessage
elif [[ $(StringValidator isSubstring "${args}" \#) ]]; then
	test ${args}
else
	${args}
fi

exit