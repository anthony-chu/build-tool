include logger.Logger

GitException(){
	curBranchException(){
		action=${1}
		branch=${2}

		Logger logErrorMsg cannot-${action}-${branch}-because-${branch}-is-the-current-branch.
	}

	existingBranchException(){
		action=${1}
		branch=${2}

		Logger logErrorMsg cannot-${action}-${branch}-because-${branch}-already-exists.
	}

	$@
}