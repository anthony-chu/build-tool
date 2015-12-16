source "c:/users/liferay/.bashrc"
source setdir.sh

pr(){
	echo "[INFO] Submitting pull request..."
	if (( !"$#" )); then
		echo "[ERROR] Missing branch, reviewer, comment, and title."
	else
		echo "  branch:			$1"
		echo "  reviewer:			$2"
		echo "  description:			$3"

		if [ -z ${4} ]; then
			title="$(git rev-parse --abbrev-ref HEAD)"
			echo "  title:			$title"
		else
			title="$4"
			echo "  title:			$title"
		fi

		echo
		cd $buildDir
		gitpr -b $1 -u $2 submit $3 $title
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
		mv ${resultDir}/index.html ${testDir}/$1_index.html

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