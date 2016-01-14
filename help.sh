source util.sh

branch_help(){
	funcList=(
		current
		delete
		dev
		list
		log
		new
		rebase
		rename
		reset
		switch
		tunnel
		)

	_maxLength "$funcList"
	_placeholder "$funcList"
	newFuncList=${newArray//\"/}
	newFuncList=(${newFuncList//[()]/})

	helpList=(
    "displays the current branch"
    "deletes the branch"
    "fetches a developer's branch"
    "displays all local branches"
    "shows the log for the current branch"
    "creates and switches to a new branch"
    "rebases the current branch to HEAD"
    "renames the current branch"
    "restores source to designated commit"
    "changes to a different local branch"
    "provides direct shell access to git directory"
    )

	echo "Usage:"
	for (( i=0; i<${#newFuncList[@]}; i++ )); do
		echo "  ${newFuncList[i]}..........${helpList[i]}"
	done
}

build_help(){
	funcList=(
		build
		clean
		pull
		push
		run
		)

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
		echo "  ${newFuncList[i]}..........${helpList[i]}"
	done
}

test_help(){
	funcList=(
	pr
	sf
	validate
	test
	)

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
		echo "  ${newFuncList[i]}..........${helpList[i]}"
	done
}