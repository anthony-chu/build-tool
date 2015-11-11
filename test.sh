source "c:/users/liferay/.bashrc"

baseDir=c:/users/liferay/Desktop
portalDir=d:/public/master-portal
implDir=$portalDir/portal-impl
newDir=d:/test-results

clean(){
	echo "[INFO] Cleaning out old test results..."
	rm -rf $newDir
	cd d:/
	mkdir $newDir
	echo "[INFO] DONE."
	cd $baseDir
}

new(){
	echo "[INFO] Checking out a new branch: $1"

	cd $portalDir

	git checkout -q -b $1

	cd $baseDir
}

pr(){
	echo "[INFO] Submitting pull request..."
	if (( !"$#" )); then
		echo "[ERROR] Missing branch, reviewer, comment, and title."
	else
		echo "  branch:   $1"
		echo "  reviewer: $2"
		echo "  comment:  $3"
		echo "  title:    $4"
		echo
		cd $portalDir
		gitpr -b $1 -u $2 submit $3 $4
		cd $baseDir
	fi
}

rebase(){
	echo "[INFO] Updating to HEAD and rebasing commits..."
	echo
	cd $portalDir
	git pull --rebase upstream master
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

sf(){
	cd $portalDir/tools/

	if [ ! -e $portalDir/tools/sdk/ ]; then
		cd $portalDir

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

show(){
	echo "[INFO] Listing all branches..."
	cd $portalDir

	git branch -q --list

	cd $baseDir
}

switch(){
	echo "[INFO] Moving to branch $1..."
	cd $portalDir

	git checkout -q $1

	cd $baseDir
}

test(){
	if (( !"$#" )); then
		echo "[ERROR] Missing test name."
	else
		echo "[INFO] Running test $1..."
		echo
		cd $portalDir
		ant -f build-test.xml run-selenium-test -Dtest.class="$1"

		testname=$1
		testname=${testname//[#]/_}

		resultDir=${portalDir}/portal-web/test-results/${testname}

		echo "[INFO] Moving test results..."
		echo
		mv ${resultDir}/index.html ${newDir}/$1_index.html

		cd $baseDir
	fi
}

validate(){
	echo "[INFO] Running POSHI validation..."
	echo
	cd $portalDir

	ant -f build-test.xml run-poshi-validation

	echo "[INFO] DONE."

	cd $baseDir
}

main(){
	if (( !"$#" )); then
		echo "Usage: $0 (commands...)"
		printf "Commands:\n    sf      runs source formatter\n    test      Runs a POSHI test\n    validate  Verifies that POSHI files are properly formatted\n    rebase  pulls current branch up to HEAD and rebases local commits on top\n    pr      makes a pull request"
		exit
	else
		if [[ $# > 1 ]]; then
			$1 ${@:2}
		else
			$1
		fi
	fi
}

clear
main $@
