source util.sh

_printHelpMessage(){
	_strToArray "$1"
	newFuncList=($array)
	_strToArray "$2"
	helpList=($array)

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		_stringReplace ${helpList[i]} "-" " "
		echo "  ${newFuncList[i]}..........${newStr}"
	done
}

branch_help(){
	funcList=(
		current
		delete
		dev
		jira
		list
		log
		new
		rebase
		rename
		reset
		switch
		tunnel
	)

	_arrayToStr ${funcList[@]}
	_maxLength "$arrayString"
	_placeholder "$arrayString"
	_strToArray "$newArray"
	newFuncList=($array)

	helpList=(
	    displays-the-current-branch
	    deletes-the-branch
	    fetches-a-developer\'s-branch
		prints-a-formatted-jira-message
	    displays-all-local-branches
	    shows-the-log-for-the-current-branch
	    creates-and-switches-to-a-new-branch
	    rebases-the-current-branch-to-HEAD
	    renames-the-current-branch
	    restores-source-to-designated-commit
	    changes-to-a-different-local-branch
	    provides-direct-shell-access-to-git-directory
    )

	_arrayToStr ${newFuncList[@]}
	newFuncListStr="$arrayString"
	_arrayToStr ${helpList[@]}
	newHelpListStr="$arrayString"

	_printHelpMessage "$newFuncListStr" "$newHelpListStr"
}

build_help(){
	funcList=(
		build
		clean
		pull
		push
		run
	)

	_arrayToStr ${funcList[@]}
	_maxLength "$arrayString"
	_placeholder "$arrayString"
	_strToArray "$newArray"
	newFuncList=($array)

	helpList=(
		builds-bundle
		rebuilds-database-and-prepares-bundle
		pulls-from-upstream-master
		pushes-to-origin-master
		runs-bundle
	)

	_arrayToStr ${newFuncList[@]}
	newFuncListStr="$arrayString"
	_arrayToStr ${helpList[@]}
	newHelpListStr="$arrayString"

	_printHelpMessage "$newFuncListStr" "$newHelpListStr"
}

test_help(){
	funcList=(
		pr
		sf
		validate
		test
	)

	_arrayToStr ${funcList[@]}
	_maxLength "$arrayString"
	_placeholder "$arrayString"
	_strToArray "$newArray"
	newFuncList=($array)

	helpList=(
		submits-a-pull-request
		formats-source-files
		runs-poshi-validation
		executes-a-frontend-test
	)

	_arrayToStr ${newFuncList[@]}
	newFuncListStr="$arrayString"
	_arrayToStr ${helpList[@]}
	newHelpListStr="$arrayString"

	_printHelpMessage "$newFuncListStr" "$newHelpListStr"
}