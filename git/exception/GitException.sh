include Message/Builder/MessageBuilder.sh

GitException(){
	curBranchException(){
		action=${1}
		branch=${2}

		MessageBuilder printErrorMessage cannot-${action}-${branch}-because-${branch}-is-the-current-branch.
	}

	existingBranchException(){
		action=${1}
		branch=${2}

		MessageBuilder printErrorMessage cannot-${action}-${branch}-because-${branch}-already-exists.
	}

	$@
}