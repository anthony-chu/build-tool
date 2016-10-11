source ${projectDir}.init.sh

include help.message.Helpmessage
include logger.Logger

package app
package base
package git
package string

_hardReset(){
	cd ${buildDir}

	git pull upstream

	git reset --hard

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}
}

changes(){
	cd ${buildDir}

	git status

	cd ${baseDir}
}

current(){
	cd ${buildDir}

	name=$(GitUtil getCurBranch)

	Logger logInfoMsg current_${branch}_branch:_${name}

	cd ${baseDir}
}

delete(){
	cd ${buildDir}

	curBranch=$(GitUtil getCurBranch)

	if [[ $(BaseComparator isEqual ${1} ${curBranch}) ]]; then
		GitException curBranchException delete ${1}
	else
		git branch -q -D ${1}
		Logger logInfoMsg deleted_local_branch:_${1}
	fi

	cd ${baseDir}
}

dev(){
	cd ${buildDir}

	local dev=${1}
	local branch=${2}

	if [[ $(StringValidator isSubstring ${branch} ee-) ]]; then
		repo=liferay-portal-ee
	else
		repo=liferay-portal
	fi

	git pull git@github.com:${dev}/${repo}.git ${branch}

	cd ${baseDir}

	log
}

jira(){
	_longLog(){
		cd ${buildDir}

		git --git-dir=${buildDir}/.git rev-parse origin/${branch}

		cd ${baseDir}
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

	case ${1} in
		fixed|nlr|repro) ${1};;
		*) ;;
	esac

	echo $(_env ${appServer})
	echo ${gitinfo}
}

list(){
	cd ${buildDir}

	GitUtil listBranches

	cd ${baseDir}
}

log(){
	cd ${buildDir}

	if [[ $(StringValidator isNull ${1}) ]]; then
		git log -1 --oneline
	elif [[ $(StringValidator isOption ${1}) ]]; then
		git log ${1} --oneline
	fi

	cd ${baseDir}
}

new(){
	cd ${buildDir}

	if [[ $(ArrayValidator hasEntry $(GitUtil listBranches) ${1}) ]]; then
		GitException existingBranchException create ${1}
	else
		git checkout -q -b ${1}
	fi

	current

	cd ${baseDir}
}

rebase(){
	abort(){
		Logger logProgressMsg terminating_previous_rebase_process

		cd ${buildDir}

		git rebase --abort

		cd ${baseDir}

		Logger logCompletedMsg
	}

	amend(){
		Logger logProgressMsg amending_the_previous_commit

		cd ${buildDir}

		git commit --amend

		cd ${baseDir}

		Logger logCompletedMsg
	}

	cont(){
		Logger logProgressMsg continuing_the_current_rebase_process

		cd ${buildDir}

		git rebase --continue

		cd ${baseDir}

		Logger logCompletedMsg
	}

	default(){
		cd ${buildDir}

		curBranch=$(GitUtil getCurBranch)

		Logger logProgressMsg rebasing_${curBranch}_against_${branch}_HEAD

		git pull --rebase upstream ${branch}

		cd ${baseDir}

		Logger logCompletedMsg
	}

	start(){
		local value=$(StringUtil returnOption ${1})

		if [[ ${value} > 1 ]]; then
			isPlural=s
		else
			isPlural=""
		fi

		Logger logProgressMsg rebasing_the_last_${value}_commit${isPlural}

		cd ${buildDir}

		git rebase -i head~${value}

		cd ${baseDir}

		Logger logCompletedMsg
	}

	if [[ $(StringValidator isNull ${1}) ]]; then
		Logger logErrorMsg please_provide_a_valid_rebase_option
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

	Logger logInfoMsg renamed_branch_from_${originalBranch}_to_${1}

	cd ${baseDir}
}

reset(){
	cd ${buildDir}

	git reset --hard ${1}

	cd ${baseDir}
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

	cd ${baseDir}
}

clear
appServer=$(AppServerValidator returnAppServer $@)
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

if [[ $(StringValidator isNull ${1}) ]]; then
	HelpMessage branchHelpMessage
else
	if [[ ${1} == ${branch} ]]; then
		shift
	fi

	$@
fi