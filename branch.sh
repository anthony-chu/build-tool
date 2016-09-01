source ${projectDir}lib/include.sh
source ${projectDir}lib/package.sh

include Comparator/Comparator.sh
include Help/Message/HelpMessage.sh
include Message/Builder/MessageBuilder.sh

package App
package Base
package String

MB=MessageBuilder

_curBranch(){
	cd ${buildDir}
	git rev-parse --abbrev-ref HEAD
	cd ${baseDir}
}

_hardReset(){
	cd ${buildDir}

	git pull upstream

	git reset --hard

	git clean -fdqx -e "*.anthonychu.properties"

	cd ${baseDir}
}

_longLog(){
	cd ${buildDir}

	git --git-dir=${buildDir}/.git rev-parse origin/${branch}

	cd ${baseDir}
}

changes(){
	cd ${buildDir}

	git status

	cd ${baseDir}
}

current(){
	name=$(_curBranch)

	cd ${buildDir}

	${MB} printInfoMessage current-${branch}-branch:-${name}

	cd ${baseDir}
}

delete(){
	curBranch=$(_curBranch)

	cd ${buildDir}

	if [[ $(Comparator isEqual ${1} ${curBranch}) ]]; then
		${MB} printErrorMessage cannot-delete-the-current-branch
	else
		git branch -q -D ${1}
		${MB} printInfoMessage deleted-local-branch:-${1}
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
	local _gitid=$(_longLog)

	if [[ $(Comparator isEqual ${branch} master) ]]; then
		branch=$(StringUtil capitalize ${branch})
	else
		branch=${branch}
	fi

	local gitinfo="Portal ${branch} GIT ID: ${_gitid}"

	fixed(){
		echo Fixed on:
	}

	nlr(){
		echo No Longer Reproducible on:
	}

	repro(){
		echo Reproduced on:
	}

	_env(){
		local appServerVersion=$(AppServerVersion
			returnAppServerVersion ${1})

		echo $(StringUtil capitalize ${1}) ${appServerVersion} + MySQL 5.7
	}

	case ${1} in
		fixed|nlr|repro) ${1};;
		*) echo "" ;;
	esac

	echo $(_env ${appServer})
	echo ${gitinfo}
}

list(){
	cd ${buildDir}

	git branch

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

	git checkout -q -b ${1}

	current

	cd ${baseDir}
}

rebase(){
	abort(){
		${MB} printProgressMessage terminating-previous-rebase-process

		cd ${buildDir}

		git rebase --abort

		cd ${baseDir}

		${MB} printDone
	}

	amend(){
		${MB} printProgressMessage amending-the-previous-commit

		cd ${buildDir}

		git commit --amend

		cd ${baseDir}

		${MB} printDone
	}

	cont(){
		${MB} printProgressMessage continuing-the-current-rebase-process

		cd ${buildDir}

		git rebase --continue

		cd ${baseDir}

		${MB} printDone
	}

	default(){
		curBranch=$(_curBranch)

		cd ${buildDir}

		${MB} printProgressMessage rebasing-${curBranch}-against-${branch}

		git pull --rebase upstream ${branch}

		cd ${baseDir}

		${MB} printDone
	}

	start(){
		local value=$(StringUtil returnOption ${1})

		if [[ ${value} > 1 ]]; then
			isPlural=s
		else
			isPlural=""
		fi

		${MB} printProgressMessage rebasing-the-last-${value}-commit${isPlural}

		cd ${buildDir}

		git rebase -i head~${value}

		cd ${baseDir}

		${MB} printDone
	}

	if [[ $(StringValidator isNull ${1}) ]]; then
		${MB} printErrorMessage please-provide-a-valid-rebase-option
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
	local originalBranch=$(_curBranch)

	cd ${buildDir}

	git branch -q -m ${1}

	${MB} printInfoMessage renamed-branch-from-${originalBranch}-to-${1}

	cd ${baseDir}
}

reset(){
	cd ${buildDir}

	git reset --hard ${1}

	cd ${baseDir}
}

search(){
	cd ${buildDir}

	args=$@

	if [[ $@ =~ ${branch} ]]; then
		args=${args//${branch}/}
	fi

	git log -a --oneline | grep "${args}"

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

tunnel(){
	cd ${buildDir}

	local tunnelCommand=""
	while [[ true ]]; do
		echo -n "Enter git command to run (begin with git): "
		read tunnelCommand

		${tunnelCommand}
		echo
		echo
	done

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