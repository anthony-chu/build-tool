source bash-toolbox/init.sh

include app.server.validator.AppServerValidator

include base.comparator.BaseComparator
include base.vars.BaseVars

include command.validator.CommandValidator

include help.message.HelpMessage

include jira.comment.util.JiraCommentUtil

include logger.Logger

include source.util.SourceUtil

include string.util.StringUtil
include string.validator.StringValidator

package git

@description displays_all_changes_made_to_current_branch
changes(){
	cd ${buildDir}

	git status
}

@description displays_the_current_branch
current(){
	cd ${buildDir}

	Logger logInfoMsg "current_${branch}_branch:_$(GitUtil getCurBranch)"
}

@description deletes_the_indicated_branch
delete(){
	cd ${buildDir}

	local curBranch=$(GitUtil getCurBranch)

	if [[ $(BaseComparator isEqual ${1} ${curBranch}) ]]; then
		GitException curBranchException delete ${1}
	else
		if ! $(git branch -q -D ${1}); then
			GitException branchDoesNotExistException delete ${1}

			return
		fi

		Logger logInfoMsg "deleted_local_branch:_${1}"
	fi
}

@description fetches_a_branch_from_a_pull_request
fetch(){
	cd ${buildDir}

	local _id=${1}

	Logger logProgressMsg "fetching_pr#${_id}_into_${branch}-ac-${_id}"

	if [[ "$(GitUtil listBranches)" =~ ${branch}-ac-${_id} ]]; then
		local message=(
			cannot_fetch_pr#${_id}_because
			branch_${branch}-ac-${_id}_exists
		)

		Logger logErrorMsg "$(StringUtil join message _)"
	else
		git fetch origin pull/${_id}/head:${branch}-ac-${_id}

		Logger logCompletedMsg
	fi
}

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

@description displays_all_local_branches
list(){
	cd ${buildDir}

	GitUtil listBranches
}

@description displays_the_log_for_the_current_branch
log(){
	cd ${buildDir}

	if [[ $(StringValidator isNull ${1}) ]]; then
		git log -1 --oneline
	elif [[ $(StringValidator isOption ${1}) ]]; then
		git log ${1} --oneline
	elif [[ ! $(StringValidator isOption ${1}) ]]; then
		Logger logErrorMsg "please_provide_a_valid_log_option"
	fi
}

@description creates_and_switches_to_the_indicated_branch
new(){
	cd ${buildDir}

	local branches=($(GitUtil listBranches))

	if [[ $(ArrayValidator hasEntry branches ${1}) ]]; then
		GitException existingBranchException create ${1}
	else
		git checkout -q -b ${1}
	fi

	current
}

@description provides_options_for_and_executes_an_interative_rebase
rebase(){
	SourceUtil clearGradleCache ${branch}

	case $(StringUtil returnOption ${1}) in
		[0-9]*) local cmd="start ${1}";;
		a) local cmd=amend;;
		c) local cmd=cont;;
		d) local cmd=default;;
		q) local cmd=abort;;
		*) Logger logErrorMsg "please_provide_a_valid_rebase_option" && exit ;;
	esac

	GitRebaseUtil ${cmd} ${branch}
}

@description renames_the_current_branch
rename(){
	cd ${buildDir}

	Logger logProgressMsg "renaming_branch_from_$(GitUtil getCurBranch)_to_${1}"

	git branch -q -m ${1}

	Logger logCompletedMsg
}

@description restores_source_code_the_designated_commit
reset(){
	cd ${buildDir}

	if [[ $(StringValidator isAlphaNum ${1}) ]]; then
		local commit=${1}
	fi

	git reset --hard ${commit}
}

@description changes_to_a_different_local_branch
switch(){
	SourceUtil clearGradleCache ${branch}

	cd ${buildDir}

	if [[ $(StringValidator isNull ${1}) ]]; then
		local b=master
	else
		local b=${1}
	fi

	local allBranches=($(GitUtil listBranches))

	if [[ ! $(StringValidator isSubstring allBranches b) ]]; then
		GitException noSuchBranchException switch_to ${b}
	else
		git checkout -q ${b}
	fi

	current
}

main(){
	@param the_app_server_\(optional\)
	local appServer=$(AppServerValidator returnAppServer ${@})

	@param the_branch_name_\(optional\)
	local branch=$(BaseVars getBranch ${@})
	local buildDir=$(BaseVars getBuildDir ${branch})
	local bundleDir=$(BaseVars getBundleDir ${branch})

	if [[ $(StringValidator isNull ${1}) ]]; then
		HelpMessage printHelpMessage
	else
		GitUtil clearIndexLock ${branch}

		CommandValidator validateCommand ${0} ${1}

		${@}
	fi
}

main $@