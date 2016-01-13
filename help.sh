_maxLength(){
	maxLength=0
	array=$funcList

	for (( i=0; i<${#array[@]}; i++ )); do
		if [[ ${#array[i]} > $maxLength ]]; then
			maxLength=${#array[i]}
		else
			maxLength=${maxLength}
		fi
	done

	export maxLength=$maxLength
}

_placeholder(){
    array=${1//\"/}
    array=(${array//[()]/""})
    maxLength=$maxLength
    newArray=""

    for (( i=0; i<${#array[@]}; i++ )); do
		arrayElement=${array[i]}
		placeholder="."

		while [ ${#arrayElement} -lt $maxLength ]; do
			arrayElement="${arrayElement}${placeholder}"
		done

		newArray="${newArray} \"${arrayElement}\""
	done

    export newArray="(${newArray})"
}

branch_help(){
	funcList="(
		\"current\"
		\"delete\"
		\"list\"
		\"log\"
		\"pullDevBranch\"
		\"new\"
		\"rebase\"
		\"rename\"
		\"reset\"
		\"switch\"
		\"tunnel\"
		)"

	_maxLength "$funcList"
	_placeholder "$funcList"
	newFuncList=${newArray//\"/}
    newFuncList=(${newFuncList//[()]/})

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
		echo "  ${newFuncList[i]}${helpList[i]}"
	done
}

build_help(){
	funcList="(
		\"build\"
		\"clean\"
		\"pull\"
		\"push\"
		\"run\"
		)"

	_maxLength "$funcList"
	_placeholder "$funcList"
	newFuncList=${newArray//\"/}
	newFuncList=(${newFuncList//[()]/})

	helpList=(
	"builds bundle"
	"rebuilds database and prepares bundle"
	"pulls from upstream master"
	"pushes to origin master"
	"runs bundle"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}${helpList[i]}"
	done
}

test_help(){
	funcList="(
		\"pr\"
		\"sf\"
		\"validate\"
		\"test\"
		)"

	_maxLength "$funcList"
	_placeholder "$funcList"
	newFuncList=${newArray//\"/}
    newFuncList=(${newFuncList//[()]/})

	helpList=(
	"submits a pull request"
	"formats source files"
	"runs poshi validation"
	"executes a front-end test"
	)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}${helpList[i]}"
	done
}