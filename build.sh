source setdir.sh

_build_log(){
	timestamp=$(_timestamp_clock)
	timestamp=${timestamp//[:]/}

	logStructure=("d" "logs" "${branch}" "$(_timestamp_date)")

	for (( i=0; i<${#logStructure[@]}; i++ )); do
		logDir=${logDir}/${logStructure[i]}
		if [ ! -e $logDir ]; then
			mkdir $logDir
			cd $logDir
		else
			cd $logDir
		fi
	done

	export logFile=$logDir/$branch-build-$(_gitlog)-${timestamp}.log
}

_clean_hard(){
	echo "[INFO] Deleting all files and folder in the bundles directory..."
	cd $bundleDir
	rm -rf deploy osgi data logs
	rm -rf $tomcatDir

	echo "[INFO] DONE."
	cd $baseDir
}

_clean_bundle(){
	echo "[INFO] Deleting liferay home folders..."
	cd $bundleDir
	rm -rf data logs
	echo "[INFO] DONE."
	echo

	cd $baseDir

	echo "[INFO] Deleting temp files..."
	cd $tomcatDir
	rm -rf temp work
	echo "[INFO] DONE."
	echo

	cd $baseDir
}

_clean_source(){
	cd $buildDir

	git reset --hard -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd $baseDir
}

_config(){
	echo "[INFO] Increasing memory limit..."
	sed -i "s/-Xmx[[:digit:]][[:digit:]][[:digit:]][[:digit:]]m/-Xmx2048m/g" $tomcatDir/bin/setenv.sh
	sed -i "s/-XX:MaxPermSize=[[:digit:]][[:digit:]][[:digit:]]m/-XX:MaxPermSize=512m/g" $tomcatDir/bin/setenv.sh
	echo "[INFO] DONE."

	if [[ $branch == ee-6.2.x ]]; then
		echo "[INFO] Changing port for ee-6.2.x..."
		sed -i "s/\"8/\"7/g" $tomcatDir/conf/server.xml
		echo "[INFO] DONE."
	fi
}

_gitlog(){
	cd $buildDir
	git log --oneline --pretty=format:%h -1
	cd $baseDir
}

_rebuild_db(){
	echo "[INFO] Rebuilding database..."
	mysql -e "drop database if exists $database; create database $database char set utf8;"
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

_timestamp_clock(){
	date +%T%s
}

_timestamp_date(){
	date +%Y%m%d
}

build(){
	_build_log

	_clean_hard

	_clean_source

	cd $buildDir

	echo "[INFO] Unzipping tomcat..."
	ant -f build-dist.xml unzip-tomcat
	echo "[INFO] DONE."

	_config

	echo "[INFO] Building portal..."
	ant all > $logFile | tail -f --pid=$$ "$logFile"
	echo "[INFO] Build complete. Please see the build log for details."
	cd $baseDir
}
clean(){
	_rebuild_db
	_clean_bundle
}

help(){
	funcList=(
	"build"
	"clean"
	"pull"
	"push"
	"run"
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
	"builds bundle"
	"rebuilds database and prepares bundle"
	"pulls from upstream master"
	"pushes to origin master"
	"runs bundle"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}  ${helpList[i]}"
	done
}

pull(){
	_clean_source

	cd $buildDir

	echo "[INFO] Pulling changes from upstream..."
	git pull upstream $branch
	echo "[INFO] DONE."
	cd $baseDir
}

push(){
	cd $buildDir

	echo "[INFO] Pushing changes to origin..."
	git push -f origin $branch
	echo "[INFO] DONE."
	cd $baseDir
}

run(){
	echo "[INFO] Starting server..."
	sleep 5s
	clear
	$tomcatDir/bin/catalina.sh run # | firefox
}

clear
getBaseDir
getDirs $@

if [[ $# == 0 ]]; then
	help
fi

while (( "$#" )); do
	$1
	shift
done
exit