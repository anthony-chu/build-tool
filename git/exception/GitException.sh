include message.builder.MessageBuilder

GitException(){
	curBranchException(){
		action=${1}
		branch=${2}

		MessageBuilder logErrorMsg cannot-${action}-${branch}-because-${branch}-is-the-current-branch.
	}

	existingBranchException(){
		action=${1}
		branch=${2}

		MessageBuilder logErrorMsg cannot-${action}-${branch}-because-${branch}-already-exists.
	}

	$@
}