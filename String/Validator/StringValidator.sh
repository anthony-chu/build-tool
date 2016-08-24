StringValidator(){
	isAlpha(){
		local str=${@}

		if [[ $(isNull ${str//[a-zA-Z ]/}) ]]; then
			echo true
		else
			return;
		fi
	}

	isAlphaNum(){
		local str=${@}

		if [[ $(isNull ${str//[0-9a-zA-Z ]}) ]]; then
			echo true
		else
			return;
		fi
	}

	isSubstring(){
		local str1=${1}
		local str2=${2}

		if [[ ${str1} =~ ${str2} ]]; then
			echo true
		else
			return;
		fi
	}

	isNull(){
		if [[ ${@} == "" ]]; then
			echo true
		else
			return;
		fi
	}

	isNum(){
		local str=${@}

		if [[ $(isNull ${str//[0-9]/}) ]]; then
			echo true
		else
			return;
		fi
	}

	$@
}