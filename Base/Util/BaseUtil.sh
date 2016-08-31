BaseUtil(){
	gitpr(){
		alias gitpr="source d:/git-tools/git-pull-request/git-pull-request.sh"
		source "c:/users/liferay/.bashrc"
		source "d:/git-tools/git-pull-request/git-pull-request.sh"
	}

	portListener(){
		if [[ $(StringValidator isNull $1) ]]; then
			exit
		else
			local port=${1}
		fi

		if [[ $(netstat -an | grep ${port} | grep LISTENING) == "" ]]; then
			return;
		else
			echo true
		fi
	}

	setJavaHome(){
		if [[ ${1} =~ 6. ]]; then
			echo "$(timestamp) [INFO] Configuring Liferay to use JDK7..."
			export JAVA_HOME="C:\Program Files\Java\jdk1.7.0_80"
			echo "$(timestamp) [INFO] Done."
		fi
	}

	timestamp(){
		if [[ ${1} == clock ]]; then
			local t=$(date +%T%s)
			echo ${t//[:]/}
		elif [[ ${1} == date ]]; then
			date +%Y%m%d
		else
			ms=$(date +%S%N)
			date +%H:%M:${ms:0:3}
		fi
	}

	$@
}