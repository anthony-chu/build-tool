include Array/Util/ArrayUtil.sh
include String/Util/StringUtil.sh

HelpMessage(){
	_printHelpMessage(){
		local everything=($@)
		local everythingSize=${#everything[@]}

		local funcList=(${everything[@]:0:${everythingSize}/2})
		local helpList=(${everything[@]:${everythingSize}/2:${everythingSize}})

		echo "Commands:"
		for (( i=0; i<${everythingSize}/2; i++ )); do
			local funcListEntry=${funcList[i]}

			local helpMessage=$(StringUtil capitalize ${helpList[i]})

			local helpListEntry=$(StringUtil replace ${helpMessage} "-" space)

			echo -e "\t${funcListEntry}................${helpListEntry}"
		done
	}

	branchHelpMessage(){
		local funcList=(
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

		local newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		local helpList=(
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
		local funcList=(
			build
			clean
			deploy
			pull
			push
			rebuild
			run
			zip
		)

		local newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		local helpList=(
			builds-bundle-on-specified-app-server
			rebuilds-database-and-prepares-bundle
			deploys-the-specified-module-to-bundle
			pulls-from-upstream-master
			pushes-current-branch-to-origin
			rebuilds-app-server-based-on-clean-and-compiled-code
			runs-a-bundle-on-specified-app-server
			zips-a-bundle-on-specified-app-server
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	ctHelpMessage(){
		local funcList=(
			build
			clean_bundle
			clean_source
			getGitId
			release
			update
		)

		local newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		local helpList=(
			builds-content-targeting-modules
			removes-content-targeting-modules-from-bundle
			removes-content-targeting-modules-from-dist-directory
			returns-the-GIT-ID-of-the-specified-branch
			generates-a-zip-of-the-content-targeting-jars
			updates-content-targeting-to-HEAD-on-current-branch
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	docsHelpMessage(){
		local optList=(
			"-d|-D"
			"-g|-G"
			"-h|-H"
			"-m|-M"
			"-s|-S"
		)

		local newOptList=$(ArrayUtil appendArrayEntry ${optList[@]})

		local helpList=(
			lists-all-dependencies-for-a-given-file
			lists-all-available-methods
			prints-this-help-message
			lists-all-methods-from-a-given-file
			lists-all-sourceable-files
		)

		_printHelpMessage ${newOptList} ${helpList[@]}
	}

	testHelpMessage(){
		local funcList=(
			pr
			sf
			validate
			test
		)

		local newFuncList=($(ArrayUtil appendArrayEntry ${funcList[@]}))

		local helpList=(
			submits-a-pull-request
			formats-source-files
			runs-poshi-validation
			executes-a-frontend-test
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	$@
}