source Array/Util/ArrayUtil.sh
source String/Util/StringUtil.sh

HelpMessage(){
	_printHelpMessage(){
		local everything=($@)
		local everythingSize=${#everything[@]}

		local funcList=(${everything[@]:0:${everythingSize}/2})
		local helpList=(${everything[@]:${everythingSize}/2:${everythingSize}})

		echo "Commands:"
		for (( i=0; i<${everythingSize}/2; i++ )); do
			funcListEntry=${funcList[i]}

			helpMessage=$(StringUtil capitalize ${helpList[i]})

			helpListEntry=$(StringUtil replace ${helpMessage} "-" space)

			echo "	${funcListEntry}................${helpListEntry}"
		done
	}

	branchHelpMessage(){
		funcList=(
			changes
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

		newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		helpList=(
			displays-all-changes-made-to-the-current-branch
			displays-the-current-branch
			deletes-the-branch
			fetches-a-developer\'s-branch
			prints-a-formatted-jira-message
			displays-all-local-branches
			shows-the-log-for-the-current-branch
			creates-and-switches-to-a-new-branch
			provides-options-for-interactive-rebase
			renames-the-current-branch
			restores-source-to-designated-commit
			changes-to-a-different-local-branch
			provides-direct-shell-access-to-git-directory
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	buildHelpMessage(){
		funcList=(
			build
			clean
			deploy
			pull
			push
			run
			zip
		)

		newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		helpList=(
			builds-bundle-on-specified-app-server
			rebuilds-database-and-prepares-bundle
			deploys-the-specified-module-to-bundle
			pulls-from-upstream-master
			pushes-current-branch-to-origin
			runs-a-bundle-on-specified-app-server
			zips-a-bundle-on-specified-app-server
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	ctHelpMessage(){
		funcList=(
			build
			cleanUpJars
			getGitId
			release
			update
		)

		newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		helpList=(
			builds-content-targeting-modules
			removes-content-targeting-modules-from-bundle
			returns-the-GIT-ID-of-the-specified-branch
			generates-a-zip-of-the-content-targeting-jars
			updates-content-targeting-to-HEAD-on-current-branch
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	docsHelpMessage(){
		optList=(
			"-d|-D"
			"-g|-G"
			"-h|-H"
			"-m|-M"
			"-s|-S"
		)

		newOptList=$(ArrayUtil appendArrayEntry ${optList[@]})

		helpList=(
			lists-all-dependencies-for-a-given-file
			lists-all-available-methods
			prints-help-message
			lists-all-methods-from-a-given-file
			lists-all-sourceable-files
		)

		_printHelpMessage ${newOptList} ${helpList[@]}
	}

	testHelpMessage(){
		funcList=(
			pr
			sf
			validate
			test
		)

		newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		helpList=(
			submits-a-pull-request
			formats-source-files
			runs-poshi-validation
			executes-a-frontend-test
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	$@
}