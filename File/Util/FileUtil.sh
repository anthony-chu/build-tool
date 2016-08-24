include String/Validator/StringValidator.sh

FileUtil(){
	getContent(){
		file=${1}

		cat ${file}
	}

	getExtension(){
		file=${1}
		echo ${file/*[.]/}
	}

	getStatus(){
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