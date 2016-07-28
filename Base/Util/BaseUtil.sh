BaseUtil(){
	gitpr(){
		alias gitpr="source d:/git-tools/git-pull-request/git-pull-request.sh"
		source "c:/users/liferay/.bashrc"
		source "d:/git-tools/git-pull-request/git-pull-request.sh"
	}

	getOS(){
		echo ${OS}
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