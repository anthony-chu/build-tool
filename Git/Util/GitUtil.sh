include Base/Util/BaseUtil.sh

GitUtil(){
	getCurBranch(){
		git rev-parse --abbrev-ref HEAD
	}

	listBranches(){
		_gitBranch=($(git branch -a))
		_curFile=$(BaseUtil getCurFile true)
		_gitBranch=(${_gitBranch[@]//remotes*/})
		echo ${_gitBranch[@]//*.sh/}
	}

	$@
}