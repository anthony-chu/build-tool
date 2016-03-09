source Array/ArrayUtil.sh
source Base/BaseVars.sh
source Help/HelpMessage.sh

pr(){
	echo "[INFO] Submitting pull request..."

	detailHeading=(branch: reviewer: comment: title:)

	newDetailHeading=($(ArrayUtil appendArrayEntry ${detailHeading[@]}))

	if (( $# == 0 )); then
		echo "[ERROR] Missing reviewer."
	else
		cd $buildDir
		title="$(git rev-parse --abbrev-ref HEAD)"
		cd $baseDir

		if [[ $title == *lps* ]]; then
			project=LPS
		elif [[ $title == *qa* ]]; then
			project=LRQA
		fi

		key=${title/master-*-}
		comment=https://issues.liferay.com/browse/${project}-${key}

		detailText=("$branch" "$1" "$comment" "$title")

		for (( i=0; i<${#detailText[@]}; i++)); do
			echo "    ${newDetailHeading[i]}................${detailText[i]}"
		done

		echo
		cd $buildDir

		git push -f origin $title

		BaseUtil gitpr -b $branch -u $1 submit $comment $title
		cd $baseDir
	fi
}

sf(){
	implDir=$buildDir/portal-impl

	cd $buildDir/tools/

	if [ ! -e $buildDir/tools/sdk/tmp/portal-tools ]; then
		cd $buildDir

		ant setup-sdk
	fi

	echo "[INFO] Running source formatter..."
	echo
	cd $implDir
	ant format-source
	echo "[INFO] DONE."
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
		echo "[ERROR] Missing test name."
	else
		echo "[INFO] Running test $1..."
		echo
		cd $buildDir
		ant -f build-test.xml run-selenium-test -Dtest.class="$1"

		testname=$1
		testname=${testname//[#]/_}

		resultDir=${buildDir}/portal-web/test-results/${testname}

		echo "[INFO] Moving test results..."
		echo

		cd $resultDir

		cd ..

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html $1_index.html

		cd $testDir/$testname
		testcase=${testname//[_]/%23}
		chromeDir="C:/Program Files (x86)/Google/Chrome/Application"
		"$chromeDir/chrome.exe" file:\/\/\/${testDir//d/D\:}/$testname/${testcase}_index.html

		cd $baseDir
	fi
}

clear
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

if [[ $# == 0 ]]; then
	HelpMessage testHelpMessage
elif [[ $@ == *#* ]]; then
	args="test $@"
	$args
else
	${@//${branch}/}
fi

exit