source Message/MessageBuilder.sh

baseDir=$(pwd)
projectDir=d:/private/ee-7.0.x-portal/modules/apps/content-targeting

MB(){
	MessageBuilder $@
}

CTBuilder(){

	build(){
		MB printProgressMessage building-content-targeting-modules

		cd ${projectDir}

		d:/private/ee-7.0.x-portal/gradlew clean deploy

		MB printDone

		cd ${baseDir}
	}

	getGitId(){
		cd ${projectDir}

		if [[ $# == 0 ]]; then
			branch=develop
		else
			branch=${1}
		fi

		curBranch=$(git rev-parse --abbrev-ref HEAD)

		if [[ ${curBranch} == ${branch} ]]; then
			echo
		else
			if [[ $(git branch) == *${branch}* ]]; then
				git checkout ${branch}
			else
				git checkout -b ${branch}
			fi
		fi

		echo "Content Targeting GIT ID: $(git --git-dir=${projectDir}/.git rev-parse origin/${branch})"
	}

	release(){
		cd ${projectDir}

		if [[ $# == 0 ]]; then
			branch=develop
		else
			branch=${1}
		fi

		curBranch=$(git rev-parse --abbrev-ref HEAD)

		if [[ ${curBranch} == ${branch} ]]; then
			echo
		else
			if [[ $(git branch) == *${branch}* ]]; then
				git checkout ${branch}
			else
				git checkout -b ${branch}
			fi
		fi

		MB printProgressMessage generating-a-release-zip-for-${branch}

		d:/private/ee-7.0.x-portal/gradlew release

		MB printDone

		cd ${baseDir}
	}

	update(){
		if [[ $# == 0 ]]; then
			branch=develop
		else
			branch=${1}
		fi

		MB printProgressMessage updating-content-targeting-on-branch-${branch}

		cd ${projectDir}

		curBranch=$(git rev-parse --abbrev-ref HEAD)

		if [[ ${curBranch} == ${branch} ]]; then
			echo
		else
			if [[ $(git branch) == *${branch}* ]]; then
				git checkout ${branch}
			else
				git checkout -b ${branch}
			fi
		fi

		git pull upstream ${branch}
		git push origin ${branch}

		MB printDone

		cd ${baseDir}
	}

	$@
}

$@ | CTBuilder $@