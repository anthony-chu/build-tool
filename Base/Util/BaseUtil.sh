BaseUtil(){
	gitpr(){
		alias gitpr="source d:/git-tools/git-pull-request/git-pull-request.sh"
		source "c:/users/liferay/.bashrc"
		source "d:/git-tools/git-pull-request/git-pull-request.sh"
	}

	getOS(){
		echo ${OS}
	}

	portListener(){
		if [[ $# == 0 ]]; then
			exit
		fi

		port=$1

		if [[ $(netstat -an | grep ${port} | grep LISTENING) == "" ]]; then
			echo false
		else
			echo true
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