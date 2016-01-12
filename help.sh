branch_help(){
	funcList=(
    "current"
    "delete"
    "list"
    "log"
    "pullDevBranch"
    "new"
    "rebase"
    "rename"
    "reset"
    "switch"
    "tunnel"
    )

	maxLength=0
	for (( i=0; i<${#funcList[@]}; i++ )); do
		if [[ ${#funcList[i]} > $maxLength ]]; then
			maxLength=${#funcList[i]}
		else
			maxLength=${maxLength}
		fi
	done

	newFuncList=()
	for (( i=0; i<${#funcList[@]}; i++ )); do
		function=${funcList[i]}
		space=" "

		while [ ${#function} -lt $maxLength ]; do
			function="${function}${space}"
		done

		newFuncList+=("${function}")
	done

	helpList=(
    "displays the current branch"
    "deletes the branch"
    "displays all local branches"
    "shows the log for the current branch"
    "fetches a developer's branch"
    "creates and switches to a new branch"
    "rebases the current branch to HEAD"
    "renames the current branch"
    "restores source to designated commit"
    "changes to a different local branch"
    "provides direct shell access to git directory"
    )

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}  ${helpList[i]}"
	done
}

build_help(){
	funcList=(
	"build"
	"clean"
	"pull"
	"push"
	"run"
	)

	maxLength=0
	for (( i=0; i<${#funcList[@]}; i++ )); do
		if [[ ${#funcList[i]} > $maxLength ]]; then
			maxLength=${#funcList[i]}
		else
			maxLength=${maxLength}
		fi
	done

	newFuncList=()
	for (( i=0; i<${#funcList[@]}; i++ )); do
		function=${funcList[i]}
		space=" "

		while [ ${#function} -lt $maxLength ]; do
			function="${function}${space}"
		done

		newFuncList+=("${function}")
	done

	helpList=(
	"builds bundle"
	"rebuilds database and prepares bundle"
	"pulls from upstream master"
	"pushes to origin master"
	"runs bundle"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}  ${helpList[i]}"
	done
}

test_help(){
	funcList=(
	"pr"
	"sf"
	"validate"
	"test"
	)

	maxLength=0
	for (( i=0; i<${#funcList[@]}; i++ )); do
		if [[ ${#funcList[i]} > $maxLength ]]; then
			maxLength=${#funcList[i]}
		else
			maxLength=${maxLength}
		fi
	done

	newFuncList=()
	for (( i=0; i<${#funcList[@]}; i++ )); do
		function=${funcList[i]}
		space=" "

		while [ ${#function} -lt $maxLength ]; do
			function="${function}${space}"
		done

		newFuncList+=("${function}")
	done

	helpList=(
	"submits a pull request"
	"formats source files"
	"runs poshi validation"
	"executes a front-end test"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}  ${helpList[i]}"
	done
}