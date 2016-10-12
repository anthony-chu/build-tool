include array.util.ArrayUtil
include string.util.StringUtil

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

			local helpListEntry=$(StringUtil replace ${helpMessage} _ space)

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
			displays_all_changes_made_to_the_current_branch
			displays_the_current_branch
			deletes_the_branch
			fetches_a_developer\'s_branch
			prints_a_formatted_jira_message
			displays_all_local_branches
			shows_the_log_for_the_current_branch
			creates_and_switches_to_a_new_branch
			provides_options_for_interactive_rebase
			renames_the_current_branch
			restores_source_to_designated_commit
			changes_to_a_different_local_branch
			provides_direct_shell_access_to_git_directory
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
			builds_bundle_on_specified_app_server
			rebuilds_database_and_prepares_bundle
			deploys_the_specified_module_to_bundle
			pulls_from_upstream_master
			pushes_current_branch_to_origin
			rebuilds_app_server_based_on_clean_and_compiled_code
			runs_a_bundle_on_specified_app_server
			zips_a_bundle_on_specified_app_server
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
			builds_content_targeting_modules
			removes_content_targeting_modules_from_bundle
			removes_content_targeting_modules_from_dist_directory
			returns_the_GIT_ID_of_the_specified_branch
			generates_a_zip_of_the_content_targeting_jars
			updates_content_targeting_to_HEAD_on_current_branch
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
			lists_all_dependencies_for_a_given_file
			lists_all_available_methods
			prints_this_help_message
			lists_all_methods_from_a_given_file
			lists_all_sourceable_files
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
			submits_a_pull_request
			formats_source_files
			runs_poshi_validation
			executes_a_frontend_test
		)

		_printHelpMessage ${newFuncList[@]} ${helpList[@]}
	}

	$@
}