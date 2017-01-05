source bash-toolbox/init.sh

include app.server.validator.AppServerValidator
include app.server.version.AppServerVersion
include app.server.version.constants.AppServerVersionConstants

include base.comparator.BaseComparator
include base.util.BaseUtil
include base.vars.BaseVars

include command.validator.CommandValidator

include git.exception.GitException
include git.util.GitUtil

include help.message.HelpMessage

include language.util.LanguageUtil

include logger.Logger

include string.util.StringUtil
include string.validator.StringValidator

_hardReset(){
	cd ${buildDir}

	git pull upstream

	git reset --hard

	git clean -fdqx -e "*.anthonychu.properties"
}

changes(){
	cd ${buildDir}

	git status
}

current(){
	cd ${buildDir}

	name=$(GitUtil getCurBranch)

	Logger logInfoMsg "current_${branch}_branch:_${name}"
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
	args=(${@})

	appServer=$(AppServerValidator returnAppServer args)

	_longLog(){
		cd ${buildDir}

		git --git-dir=${buildDir}/.git rev-parse origin/${branch}
	}

	if [[ $(BaseComparator isEqual ${branch} master) ]]; then
		branch=$(StringUtil capitalize ${branch})
	else
		branch=${branch}
	fi

	local gitinfo="Portal ${branch} GIT ID: $(_longLog)"

	fixed(){
		echo \*Fixed on:\*
	}

	nlr(){
		echo \*No Longer Reproducible on:\*
	}

	repro(){
		echo \*Reproduced on:\*
	}

	_env(){
		local appServerVersion=$(AppServerVersion
			returnAppServerVersion ${1} ${branch})

		echo $(StringUtil capitalize ${1}) ${appServerVersion} + MySQL 5.7
	}

	if [[ $(BaseComparator isEqual ${1} fixed) || $(BaseComparator
		isEqual ${1} nlr) || $(BaseComparator isEqual ${1} repro) ]]; then

		${1}
	fi

	echo $(_env ${appServer})
	echo ${gitinfo}
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
	abort(){
		Logger logProgressMsg "terminating_previous_rebase_process"

		cd ${buildDir}

		git rebase --abort

		Logger logCompletedMsg
	}

	amend(){
		Logger logProgressMsg "amending_the_previous_commit"

		cd ${buildDir}

		git commit --amend

		Logger logCompletedMsg
	}

	cont(){
		Logger logProgressMsg "continuing_the_current_rebase_process"

		cd ${buildDir}

		git rebase --continue

		Logger logCompletedMsg
	}

	default(){
		cd ${buildDir}

		curBranch=$(GitUtil getCurBranch)

		Logger logProgressMsg "rebasing_${curBranch}_against_${branch}_HEAD"

		git pull --rebase upstream ${branch}

		Logger logCompletedMsg
	}

	start(){
		local value=$(StringUtil returnOption ${1})

		Logger logProgressMsg "rebasing_the_last_${value}_$(LanguageUtil togglePlurality ${value} commit commits)"

		cd ${buildDir}

		git rebase -i head~${value}

		Logger logCompletedMsg
	}

	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg "please_provide_a_valid_rebase_option"
		exit
	fi

	case $(StringUtil returnOption ${1}) in
		[0-9]*) start ${1};;
		a) amend;;
		c) cont;;
		d) default;;
		q) abort;;
	esac
}

rename(){
	cd ${buildDir}

	local originalBranch=$(GitUtil getCurBranch)

	git branch -q -m ${1}

	Logger logInfoMsg "renamed_branch_from_${originalBranch}_to_${1}"
}

reset(){
	cd ${buildDir}

	if [[ $(StringValidator isAlphaNum ${1}) ]]; then
		commit=${1}
	fi

	git reset --hard ${commit}
}

switch(){
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
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

if [[ $(StringValidator isNull ${1}) ]]; then
	HelpMessage branchHelpMessage
else
	CommandValidator validateCommand ${0} ${1}

	$@
fi