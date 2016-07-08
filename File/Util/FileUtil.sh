FileUtil(){
	getFileExtension(){
		file=${1}
		echo ${file/*[.]/}
	}

	getFileStatus(){
		if [[ $(ls | grep ${1}) == "" ]]; then
			echo false
		else
			if [[ $(ls | grep ${1}) == ${1} ]]; then
				echo true
			else
				echo false
			fi
		fi
	}

	matchFileContentSubstring(){
		pattern=${1}
		file=${2}

		matchingContent=($(grep -o ${pattern} ${file}))

		if [[ ${matchingContent[@]} == "" ]]; then
			echo false
		else
			echo true
		fi
	}

	$@
}