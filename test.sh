source Array/ArrayUtil.sh
source Base/BaseUtil.sh
source Base/BaseVars.sh
source Help/HelpMessage.sh
source Message/MessageBuilder.sh
source String/StringUtil.sh

MB=MessageBuilder

mockmock(){
	cd $buildDir

	$MB printInfoMessage "Building MockMock jar.."

	ant -f build-test.xml start-test-smtp-server

	clear

	$MB printInfoMessage "Starting MockMock SMTP server.."

	sleep 5s

	clear

	cd lib/development

	java -jar MockMock.jar
}

pr(){
	if (( $# == 0 )); then
		$MB printErrorMessage "Missing reviewer"
	else
		$MB printInfoMessage "Submitting pull request.."

		detailHeading=(branch: reviewer: comment: title:)

		newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

		cd $buildDir
		title="$(git rev-parse --abbrev-ref HEAD)"
		cd $baseDir

		if [[ $title == *lps* ]]; then
			project=LPS
		elif [[ $title == *qa* ]]; then
			project=LRQA
		fi

		key=${title/${branch}-*-}
		comment=https://issues.liferay.com/browse/${project}-${key}

		if [[ $# == 1 ]]; then
			branch=$branch
			user=$1
		else
			branch=$1
			user=$2
		fi

		detailText=("$branch" "$user" "$comment" "$title")

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo "	${newDetailHeading[i]}................${detailText[i]}"
		done

		echo
		cd $buildDir

		git push -f origin $title

		BaseUtil gitpr -b $branch -u $user submit $comment $title
		cd $baseDir

		$MB printDone
	fi
}

sf(){
	implDir=$buildDir/portal-impl

	cd $buildDir/tools/

	if [ ! -e $buildDir/tools/sdk/tmp/portal-tools ]; then
		cd $buildDir

		ant setup-sdk
	fi

	$MB printInfoMessage "Running source formatter.."
	echo
	cd $implDir
	ant format-source-local-changes
	$MB printDone
	echo
	cd $baseDir
}

validate(){
	cd $buildDir

	ant -f build-test.xml run-poshi-validation

	cd $baseDir
}

test(){
	testStructure=("d" "test-results" "${branch}")

	for (( i=0; i<${#testStructure[@]}; i++ )); do
		testDir=${testDir}/${testStructure[i]}
		if [ ! -e $testDir ]; then
			mkdir $testDir
			cd $testDir
		else
			cd $testDir
		fi
	done

	if (( !"$#" )); then
		$MB printErrorMessage "Missing test name"
	else
		test=$1
		shift
		$MB printInfoMessage "Running test $test.."
		echo
		cd $buildDir
		ant -f build-test.xml run-selenium-test -Dtest.class="$test" $@

		testname=$(StringUtil replace $test "#" _)

		resultDir=${buildDir}/portal-web/test-results/${testname}

		$MB printInfoMessage "Moving test results.."
		echo

		cd $resultDir

		cd ..

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		cd $testDir/$testname
		testcase=${testname//[_]/%23}
		chromeDir="C:/Program Files (x86)/Google/Chrome/Application"

		file="\/\/\/${testDir//d/D\:}/$testname/${testcase}_index.html"

		"$chromeDir/chrome.exe" "file:${file}"

		cd $baseDir
	fi
}

clear
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

args=$@

if [[ $@ == ${branch} ]]; then
	args=${@/$branch/}
fi

if [[ $# == 0 ]]; then
	HelpMessage testHelpMessage
elif [[ $args == *#* ]]; then
	test $args
else
	$args
fi

exit