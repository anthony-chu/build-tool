source Help/Message/HelpMessage.sh
source Message/Builder/MessageBuilder.sh
source String/Validator/StringValidator.sh

baseDir=$(pwd)
projectDir=d:/private/ee-7.0.x-portal/modules/apps/content-targeting
distDir=${projectDir}/../../../tools/sdk/dist

CTBuilder(){

	MB=MessageBuilder
	SV=StringValidator

	_branchChecker(){
		if [[ $(${SV} isNull ${1}) == true ]]; then
			branch=develop
		else
			branch=${1}
		fi

		echo ${branch}
	}

	_branchSwitcher(){
		curBranch=$(git rev-parse --abbrev-ref HEAD)

		if [[ $(${SV} isEqual ${curBranch} ${1}) == true ]]; then
			echo
		else
			allBranches=($(git branch -a | grep origin))

			for (( i=0; i<${#allBranches[@]}; i++ )); do
				if [[ $(${SV} isEqual ${allBranches[i]/remotes\/origin\//} ${1}) == false ]]; then
					${MB} printErrorMessage the-branch-${1}-does-not-exist-in-origin
					doSwitch=false
				else
					doSwitch=true
				fi
			done

			if [[ ${doSwitch} == true ]]; then
				git checkout ${1}
			else
				exit
			fi
		fi
	}

	build(){
		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		${MB} printProgressMessage building-content-targeting-modules

		d:/private/ee-7.0.x-portal/gradlew clean deploy

		${MB} printDone

		cd ${baseDir}
	}

	cleanUpJars(){
		${MB} printProgressMessage removing-content-targeting-jars-from-the-bundle

		cd D:/private/ee-7.0.x-bundles/osgi/modules

		rm -rf *content.targeting*

		cd ${baseDir}

		${MB} printDone
	}

	getGitId(){
		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		gitId=$(git --git-dir=${projectDir}/.git rev-parse origin/${branch})

		echo "Content Targeting GIT ID: ${gitId}"
	}

	release(){
		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		${MB} printProgressMessage generating-a-release-zip-for-${branch}

		d:/private/ee-7.0.x-portal/gradlew release

		${MB} printDone

		cd ${baseDir}
	}

	update(){
		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		${MB} printProgressMessage updating-content-targeting-on-branch-${branch}

		git pull upstream ${branch}
		git push origin ${branch}

		${MB} printDone

		cd ${baseDir}
	}

	$@
}

if [[ $@ != CTBuilder* ]]; then
	if [[ $# == 0 ]]; then
		HelpMessage ctHelpMessage
	else
		CTBuilder $@
	fi
fi