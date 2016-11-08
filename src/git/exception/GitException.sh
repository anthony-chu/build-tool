include logger.Logger

GitException(){
	curBranchException(){
		action=${1}
		branch=${2}

		Logger logErrorMsg "cannot_${action}_${branch}_because_${branch}_is_the_
			current_branch"
	}

	existingBranchException(){
		action=${1}
		branch=${2}

		Logger logErrorMsg "cannot_${action}_${branch}_because_${branch}_already
			_exists"
	}

	$@
}