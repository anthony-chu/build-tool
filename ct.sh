source ${projectDir}.init.sh

include base.comparator.BaseComparator
include git.util.GitUtil
include help.message.HelpMessage
include logger.Logger

package string

baseDir=$(pwd)
projectDir=d:/private/ee-7.0.x-portal/modules/apps/content-targeting
distDir=${projectDir}/../../../tools/sdk/dist

CTBuilder(){

	C_isEqual="BaseComparator isEqual"
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
				if [[ $(${C_isEqual} $(StringUtil
					replace ${b} remotes\/origin\/) ${1}) ]]; then

					Logger logErrorMsg the_branch_${1}_does_not_exist_in_origin
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

		Logger logProgressMsg building_content_targeting_modules

		_generateSnapshot

		d:/private/ee-7.0.x-portal/gradlew clean deploy

		Logger logCompletedMsg

		cd ${baseDir}
	}

	clean_bundle(){
		Logger logProgressMsg removing_content_targeting_jars_from_the_bundle

		cd D:/private/ee-7.0.x-bundles/osgi/modules

		_clean

		cd ${baseDir}

		Logger logCompletedMsg
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

		Logger logProgressMsg generating_a_release_zip_for_${branch}

		d:/private/ee-7.0.x-portal/gradlew release

		Logger logCompletedMsg

		cd ${baseDir}
	}

	update(){
		cd ${projectDir}

		_branchSwitcher $(_branchChecker ${1})

		Logger logProgressMsg updating_content_targeting_on_branch_${branch}

		git pull upstream ${branch}
		git push origin ${branch}

		Logger logCompletedMsg

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