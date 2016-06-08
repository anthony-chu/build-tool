source Message/MessageBuilder.sh

baseDir=$(pwd)
projectDir=d:/private/ee-7.0.x-portal/modules/apps/content-targeting

MB(){
	MessageBuilder $@
}

CTBuilder(){
	_branchChecker(){
		if [[ ${1} == "" ]]; then
			branch=develop
		else
			branch=${1}
		fi
	}

	_branchSwitcher(){
		curBranch=$(git rev-parse --abbrev-ref HEAD)

		if [[ ${curBranch} == ${1} ]]; then
			echo
		else
			if [[ $(git branch) == *${1}* ]]; then
				git checkout ${1}
			else
				git checkout -b ${1}
			fi
		fi
	}

	build(){
		MB printProgressMessage building-content-targeting-modules

		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		d:/private/ee-7.0.x-portal/gradlew clean deploy

		MB printDone

		cd ${baseDir}
	}

	getGitId(){
		cd ${projectDir}

		branch=$(_branchChecker $1)

		_branchSwitcher ${branch}

		echo "Content Targeting GIT ID: $(git --git-dir=${projectDir}/.git rev-parse origin/${branch})"
	}

	release(){
		MB printProgressMessage generating-a-release-zip-for-${branch}

		cd ${projectDir}

		branch=$(_branchChecker $1)

		_branchSwitcher ${branch}

		d:/private/ee-7.0.x-portal/gradlew release

		MB printDone

		cd ${baseDir}
	}

	update(){
		MB printProgressMessage updating-content-targeting-on-branch-${branch}

		cd ${projectDir}

		branch=$(_branchChecker ${1})

		_branchSwitcher ${branch}

		git pull upstream ${branch}
		git push origin ${branch}

		MB printDone

		cd ${baseDir}
	}

	$@
}

if [[ $@ != CTBuilder* ]]; then
	CTBuilder $@
fi