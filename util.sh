gitpr(){
	alias gitpr="source d:/git-tools/git-pull-request/git-pull-request.sh"
	source "c:/users/liferay/.bashrc"
	source "d:/git-tools/git-pull-request/git-pull-request.sh"
}

getOption(){
	if [[ $1 == -[a-zA-Z0-9]* ]]; then
		echo ${1/-/ }
	fi
}