source ${projectDir}String/Validator/StringValidator.sh

FileUtil(){
	getFileExtension(){
		file=${1}
		echo ${file/*[.]/}
	}

	getFileStatus(){
		if [[ $(StringValidator isNull $(ls | grep ${1})) == true ]]; then
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

		if [[ $(StringValidator isNull ${matchingContent[@]}) == true ]]; then
			echo false
		else
			echo true
		fi
	}

	$@
}