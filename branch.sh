source bash-toolbox/init.sh

include app.server.validator.AppServerValidator

include command.validator.CommandValidator

include help.message.HelpMessage

include jira.comment.util.JiraCommentUtil

include repo.Repo

@description prints_a_formatted_Jira_comment
jira(){
	local cmd=""

	local args="${appServer} ${branch}"

	if [[ $@ =~ "nightly" ]]; then
		local args="${args} nightly"
	fi

	case ${1} in
		-f|--fixed|fixed) local cmd="fixed" ;;
		-n|--nlr|nlr) local cmd="nlr" ;;
		-r|--repro|repro) local cmd="repro" ;;
		-t|--tested|tested) local cmd="tested" ;;
	esac

	JiraCommentUtil ${cmd} ${args}
}

main(){
	if [[ ! ${1} ]]; then
		HelpMessage printHelpMessage
	else
		CommandValidator validateCommand ${0} ${1}

		@param the_app_server_\(optional\)
		local appServer=$(AppServerValidator returnAppServer ${@})

		@param the_branch_name_\(optional\)
		local branch=$(Repo getBranch ${@})
		local buildDir=$(Repo getBuildDir ${branch})
		local bundleDir=$(Repo getBundleDir ${branch})

		${@}
	fi
}

main $@