source ${projectDir}.init.sh

include base.comparator.BaseComparator
include git.util.GitUtil
include help.message.HelpMessage
include message.builder.MessageBuilder

package string

baseDir=$(pwd)
projectDir=d:/private/ee-7.0.x-portal/modules/apps/content-targeting
distDir=${projectDir}/../../../tools/sdk/dist

CTBuilder(){

	C_isEqual="BaseComparator isEqual"
	MB=MessageBuilder
	SV=StringValidator

	_branchChecker(){
		if [[ $(${SV} isNull ${1}) ]]; then
			branch=develop
		else
			branch=${1}
		fi

		echo ${branch}
	}

	_branchSwitcher(){
		curBranch=$(GitUtil getCurBranch)

		if [[ $(${C_isEqual} ${curBranch} ${1}) ]]; then
			echo
		else
			for b in $(GitUtil listBranches); do
				if [[ $(${C_isEqual} $(StringUtil replace ${b} remotes\/origin\/) ${1}) ]]; then
					${MB} logErrorMsg the-branch-${1}-does-not-exist-in-origin
				else
					doSwitch=true
				fi
			done

			if [[ ${doSwitch} ]]; then
				git checkout ${1}
			else
				exit
			fi
		fi
	}

	_clean(){
		rm *content.targeting*.jar
	}

	_generateSnapshot(){
		cd ${projectDir}/content-targeting-api

		${projectDir}/../../../gradlew install -P snapshot

		cd ${projectDir}
	}

	build(){
		clean_source

		cd ${projectDir}

		_branchSwitcher $(_branchChecker ${1})

		${MB} logProgressMsg building-content-targeting-modules

		_generateSnapshot

		d:/private/ee-7.0.x-portal/gradlew clean deploy

		${MB} logCompletedMsg

		cd ${baseDir}
	}

	clean_bundle(){
		${MB} logProgressMsg removing-content-targeting-jars-from-the-bundle

		cd D:/private/ee-7.0.x-bundles/osgi/modules

		_clean

		cd ${baseDir}

		${MB} logCompletedMsg
	}

	clean_source(){
		cd ${distDir}

		_clean

		cd ${baseDir}
	}

	getGitId(){
		cd ${projectDir}

		_branchSwitcher $(_branchChecker ${1})

		gitId=$(git --git-dir=${projectDir}/.git rev-parse origin/${branch})

		echo "Content Targeting GIT ID: ${gitId}"
	}

	release(){
		cd ${projectDir}

		_branchSwitcher $(_branchChecker ${1})

		${MB} logProgressMsg generating-a-release-zip-for-${branch}

		d:/private/ee-7.0.x-portal/gradlew release

		${MB} logCompletedMsg

		cd ${baseDir}
	}

	update(){
		cd ${projectDir}

		_branchSwitcher $(_branchChecker ${1})

		${MB} logProgressMsg updating-content-targeting-on-branch-${branch}

		git pull upstream ${branch}
		git push origin ${branch}

		${MB} logCompletedMsg

		cd ${baseDir}
	}

	$@
}

if [[ $@ != CTBuilder* ]]; then
	if [[ $(StringValidator isNull ${1}) ]]; then
		HelpMessage ctHelpMessage
	else
		CTBuilder $@
	fi
fi