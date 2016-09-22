include string.validator.StringValidator

FileUtil(){
	getContent(){
		local file=${1}

		cat ${file}
	}

	getExtension(){
		local file=${1}
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
		local pattern=${1}
		local file=${2}

		local matchingContent=($(grep -o '${pattern}' ${file}))

		if [[ $(ArrayValidator hasEntry ${matchingContent[@]} ${pattern}) ]]; then
			return;
		else
			echo true
		fi
	}

	$@
}