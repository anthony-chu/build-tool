source "c:/users/liferay/.bashrc"
source setdir.sh

help(){
	funcList=(
	"pr"
	"sf"
	"validate"
	"test"
	)

	maxLength=0
	for (( i=0; i<${#funcList[@]}; i++ )); do
		if [[ ${#funcList[i]} > $maxLength ]]; then
			maxLength=${#funcList[i]}
		else
			maxLength=${maxLength}
		fi
	done

	newFuncList=()
	for (( i=0; i<${#funcList[@]}; i++ )); do
		function=${funcList[i]}
		space=" "

		while [ ${#function} -lt $maxLength ]; do
			function="${function}${space}"
		done

		newFuncList+=("${function}")
	done

	helpList=(
	"submits a pull request"
	"formats source files"
	"runs poshi validation"
	"executes a front-end test"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}  ${helpList[i]}"
	done
}

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
			echo "    ${newDetailHeading[i]} ${detailText[i]}"
		done

		echo
		cd $buildDir
		gitpr -b $branch -u $1 submit $comment $title
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

		cd $baseDir
	fi
}

clear
getBaseDir
getDirs $@

if [[ $# == 0 ]]; then
	help
elif [[ $@ == *#* ]]; then
	args="test $@"
	$args
else
	$@
fi

exit