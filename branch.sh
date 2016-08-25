source ${projectDir}lib/include.sh
source ${projectDir}lib/package.sh

include Help/Message/HelpMessage.sh
include Message/Builder/MessageBuilder.sh
include String/Validator/StringValidator.sh

package App
package Base

MB=MessageBuilder

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
  cd ${buildDir}

  name=$(git rev-parse --abbrev-ref HEAD)

  ${MB} printInfoMessage current-${branch}-branch:-${name}

  cd ${baseDir}
}

delete(){
	cd ${buildDir}

	if [[ ${1} == $(git rev-parse --abbrev-ref HEAD) ]]; then
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

	git pull git@github.com:${dev}/liferay-portal.git ${branch}

	cd ${baseDir}

	log
}

jira(){
	local _gitid=$(_longLog)

	if [[ ${branch} == master ]]; then
		branch=${branch^}
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
			returnAppServerVersion ${appServer})

		echo ${appServer^} ${appServerVersion} + MySQL 5.7
	}

	case ${1} in
		fixed|nlr|repro) ${1};;
		*) echo "" ;;
	esac

	echo $(_env ${2})
	echo ${gitinfo}
}

list(){
  cd ${buildDir}

  git branch

  cd ${baseDir}
}

log(){
	cd ${buildDir}

	if [[ $# == 0 ]]; then
		git log -1 --oneline
	else
		git log -${1} --oneline
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
		${MB} printProgressMessage rebasing-current-branch-to-head

		cd ${buildDir}

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
		q) abort;;
		c) cont;;
		a) amend;;
		d) default;;
	esac
}

rename(){
	cd ${buildDir}

	local originalBranch=$(git rev-parse --abbrev-ref HEAD)

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

  if [[ $# == 0 ]]; then
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

if [[ $# == 0 ]]; then
  HelpMessage branchHelpMessage
else
	if [[ ${1} == ${branch} ]]; then
		shift
	fi

	$@
fi