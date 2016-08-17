include String/Validator/StringValidator.sh

FileUtil(){
	getFileExtension(){
		file=${1}
		echo ${file/*[.]/}
	}

	getFileStatus(){
		if [[ $(StringValidator isNull $(ls | grep ${1})) ]]; then
			return;
		else
			if [[ $(ls | grep ${1}) == ${1} ]]; then
				echo true
			else
				return;
			fi
		fi
	}

	matchFileContentSubstring(){
		pattern=${1}
		file=${2}

		matchingContent=($(grep -o ${pattern} ${file}))

		if [[ $(StringValidator isNull ${matchingContent[@]}) ]]; then
			return;
		else
			echo true
		fi
	}

	$@
}