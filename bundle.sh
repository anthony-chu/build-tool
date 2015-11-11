baseDir=c:/users/liferay/Desktop

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

_clean_database(){
	echo "[INFO] Rebuilding database..."
	mysql -e "drop database if exists $database; create database $database char set utf8;"
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

_clean_hard(){
	echo "[INFO] Deleting all files and folder in the bundles directory..."
	cd $bundleDir
	rm -rf $bundleDir/data $bundleDir/deploy $bundleDir/logs $bundleDir/osgi
	rm -rf $tomcatDir
	echo "[INFO] DONE."
	cd $baseDir
}

_clean_liferay_home(){
	echo "[INFO] Deleting liferay home folders..."
	cd ${bundleDir}
	rm -rf $bundleDir/data $bundleDir/logs
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

_clean_source(){
	cd $buildDir
	git reset --hard -q
	git checkout $branch -q

	git clean -fdqx -e "*.anthonychu.properties"

	cd $baseDir
}

_clean_temp_files(){
	echo "[INFO] Deleting temp files..."
	cd $tomcatDir
	rm -rf temp work
	echo "[INFO] DONE."
	echo
	cd $baseDir
}

_config(){
	echo "[INFO] Increasing memory limit..."
	sed -i "s/-Xmx1024m/-Xmx2048m/g" $tomcatDir/bin/setenv.sh
	sed -i "s/-XX:MaxPermSize=256m/-XX:MaxPermSize=512m/g" $tomcatDir/bin/setenv.sh
	echo "[INFO] DONE."

	if [[ $branch == ee-6.2.x ]]; then
		echo "[INFO] Changing port for ee-6.2.x..."
		sed -i "s/\"8/\"7/g" $tomcatDir/conf/server.xml
	fi
}

clean(){
	_clean_database
	_clean_liferay_home
	_clean_temp_files
}

_gitlog(){
	cd $buildDir
	git log --oneline --pretty=format:%h -1
	cd $baseDir
}

getDirs(){
	args=$@

	if [[ $args == *master* ]]; then
		branch=master
	elif [[ $args == *ee-6.2.x* ]]; then
		branch=ee-6.2.x
	else
		branch=master
	fi

	args=${args/$branch/""}

	case $branch in
		"master") buildDir=d:/public/master-portal; bundleDir=d:/public/master-bundles; database=lportalmaster;;
		"ee-6.2.x") buildDir=d:/private/ee-6.2.x-portal; bundleDir=d:/private/ee-6.2.x-bundles; database=lportal;;
	esac

	export args="${args}" branch="${branch}" buildDir="${buildDir}" bundleDir="${bundleDir}" database="${database}" tomcatDir="$bundleDir/tomcat-7.0.62/"
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

_timestamp_clock(){
	date +%T%s
}

_timestamp_date(){
	date +%Y%m%d
}

main(){
	if (( !"$#" )); then
		echo "Usage: $0 (commands...)"
		echo "Commands:"
		echo "    build     builds a bundle"
		echo "    clean     prepares a fresh bundle"
		echo "    pull      pulls changes from upstream"
		echo "    push      pushes changes to origin"
		echo "    run       runs a bundle"
		exit
	fi

	while (( "$#" )); do
		$1
		shift
	done
}

clear
getDirs $@
main $args