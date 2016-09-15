include Base/Util/BaseUtil.sh

GitUtil(){
	getCurBranch(){
		git rev-parse --abbrev-ref HEAD
	}

	listBranches(){
		git branch | sed s/\*//g
	}

	$@
}