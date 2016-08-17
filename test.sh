source ${projectDir}lib/include.sh

include Array/Util/ArrayUtil.sh
include Comparator/Comparator.sh
include File/Name/Util/FileNameUtil.sh
include Base/Util/BaseUtil.sh
include Base/Vars/BaseVars.sh
include File/Name/Util/FileNameUtil.sh
include Help/Message/HelpMessage.sh
include Message/Builder/MessageBuilder.sh
include String/Util/StringUtil.sh

C_isEqual="Comparator isEqual"
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
	if (( $# == 0 )); then
		${MB} printErrorMessage missing-reviewer
	else
		${MB} printProgressMessage submitting-pull-request

		detailHeading=(branch: reviewer: comment: title:)

		newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

		cd ${buildDir}
		title="$(git rev-parse --abbrev-ref HEAD)"
		cd ${baseDir}

		branchArray=($(StringUtil replace ${branch} - space))

		for (( i=0; i<${#branchArray[@]}; i++ )); do
			if [[ $(${C_isEqual} ${branchArray[i]} qa) ]]; then
				project=LRQA
				key=${branchArray[i+1]}
				break
			elif [[ $(${C_isEqual} ${branchArray[i]} lps) ]]; then
				project=LPS
				key=${branchArray[i+1]}
				break
			fi
		done

		comment=https://issues.liferay.com/browse/${project}-${key}

		if [[ $# == 1 ]]; then
			branch=${branch}
			user=${1}
		else
			branch=${1}
			user=${2}
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
	implDir=${buildDir}/portal-impl

	cd ${buildDir}/tools/

	sf_lib="tools/sdk/dependencies/com.liferay.source.formatter/lib"

	if [ ! -e ${buildDir}/${sf_lib} ]; then
		cd ${buildDir}

		ant setup-sdk
	fi

	cd ${implDir}

	if [[ ${1} =~ a ]] || [[ ${1} =~ A ]]; then
		localChanges=""

		${MB} printProgressMessage running-source-formatter-on-all-files
		echo
	elif [[ ${1} =~ l ]] || [[ ${1} =~ L ]]; then
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

	if (( !"$#" )); then
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

args=$@

if [[ $@ =~ ${branch} ]]; then
	args=${@/${branch}/}
fi

if [[ $# == 0 ]]; then
	HelpMessage testHelpMessage
elif [[ ${args} == *#* ]]; then
	test ${args}
else
	${args}
fi

exit