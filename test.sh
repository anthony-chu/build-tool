source "c:/users/liferay/.bashrc"
source setdir.sh

pr(){
	echo "[INFO] Submitting pull request..."

	detailHeading=("branch:" "reviewer:" "comment:" "title:")

	maxLength=0
	for (( i=0; i<${#detailHeading[@]}; i++ )); do
		if [[ ${#detailHeading[i]} > $maxLength ]]; then
			maxLength=${#detailHeading[i]}
		else
			maxLength=${maxLength}
		fi
	done

	newDetailHeading=()
	for (( i=0; i<${#detailHeading[@]}; i++ )); do
		detail=${detailHeading[i]}
		space=" "

		while [ ${#detail} -lt $maxLength ]; do
			detail="${detail}${space}"
		done

		newDetailHeading+=("${detail}")
	done

	if (( !"$#" )); then
		echo "[ERROR] Missing branch, reviewer, comment, and title."
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
			echo "    ${newDetailHeading[i]} ${detailText[i]}"
		done

		echo
		cd $buildDir
		gitpr -b $branch -u $1 submit $comment $title
		cd $baseDir
	fi
}

rebase(){
	echo "[INFO] Updating to HEAD and rebasing commits..."
	echo
	cd $buildDir
	git pull --rebase upstream master
	echo "[INFO] DONE."
	echo
	cd $baseDir
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

		cd $baseDir
	fi
}


main(){
	if [[ $# > 1 ]]; then
		$1 ${@:2}
	else
		if [[ $args == *#* ]]; then
			args="test $args"
			$args
		else
			$1
		fi
	fi
}

clear
getBaseDir
getDirs $@
main $args