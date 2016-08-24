StringValidator(){
	isAlpha(){
		local str=${@}

		isNull ${str//[a-zA-Z ]/}
	}

	isAlphaNum(){
		local str=${@}

		isNull ${str//[0-9a-zA-Z ]}
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

		isNull ${str//[0-9]/}
	}

	$@
}