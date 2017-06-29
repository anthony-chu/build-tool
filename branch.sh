source bash-toolbox/init.sh

include app.server.validator.AppServerValidator

include base.comparator.BaseComparator
include base.vars.BaseVars

include command.validator.CommandValidator

include help.message.HelpMessage

include jira.util.JiraUtil

include logger.Logger

include source.util.SourceUtil

include string.util.StringUtil
include string.validator.StringValidator

package git

changes(){
	cd ${buildDir}

	git status
}

current(){
	cd ${buildDir}

	Logger logInfoMsg "current_${branch}_branch:_$(GitUtil getCurBranch)"
}

delete(){
	cd ${buildDir}

	curBranch=$(GitUtil getCurBranch)

	if [[ $(BaseComparator isEqual ${1} ${curBranch}) ]]; then
		GitException curBranchException delete ${1}
	else
		git branch -q -D ${1}
		Logger logInfoMsg "deleted_local_branch:_${1}"
	fi
}

dev(){
	cd ${buildDir}

	local dev=${1}
	local branch=${2}

	if [[ $(BaseVars isPrivate ${branch}) ]]; then
		repo=liferay-portal-ee
	else
		repo=liferay-portal
	fi

	git pull git@github.com:${dev}/${repo}.git ${branch}

	log
}

jira(){
	if [[ $(BaseComparator isEqual ${1} fixed) || $(
		BaseComparator isEqual ${1} nlr) || $(
		BaseComparator isEqual ${1} repro) || ! ${1} ]]; then

		JiraUtil ${1} ${appServer} ${branch}
	fi
}

list(){
	cd ${buildDir}

	GitUtil listBranches
}

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

rebase(){
	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg "please_provide_a_valid_rebase_option"
		exit
	fi

	SourceUtil clearGradleCache ${branch}

	case $(StringUtil returnOption ${1}) in
		[0-9]*) local cmd="start ${1}";;
		a) local cmd=amend;;
		c) local cmd=cont;;
		d) local cmd=default;;
		q) local cmd=abort;;
	esac

	GitRebaseUtil ${cmd} ${branch}
}

rename(){
	cd ${buildDir}

	Logger logProgressMsg "renaming_branch_from_$(GitUtil getCurBranch)_to_${1}"

	git branch -q -m ${1}

	Logger logCompletedMsg
}

reset(){
	cd ${buildDir}

	if [[ $(StringValidator isAlphaNum ${1}) ]]; then
		commit=${1}
	fi

	git reset --hard ${commit}
}

switch(){
	SourceUtil clearGradleCache ${branch}

	cd ${buildDir}

	if [[ $(StringValidator isNull ${1}) ]]; then
		b=master
	else
		b=${1}
	fi

	git checkout -q ${b}

	current
}

clear
appServer=$(AppServerValidator returnAppServer ${@})
branch=$(BaseVars returnBranch ${@})
buildDir=$(BaseVars returnBuildDir ${branch})
bundleDir=$(BaseVars returnBundleDir ${branch})

if [[ $(StringValidator isNull ${1}) ]]; then
	HelpMessage branchHelpMessage
else
	GitUtil clearIndexLock ${branch}

	CommandValidator validateCommand ${0} ${1}

	${@}
fi