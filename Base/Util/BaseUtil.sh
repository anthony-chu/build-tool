BaseUtil(){
	gitpr(){
		alias gitpr="source ${projectDir}d:/git-tools/git-pull-request/git-pull-request.sh"
		source ${projectDir}"c:/users/liferay/.bashrc"
		source ${projectDir}"d:/git-tools/git-pull-request/git-pull-request.sh"
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