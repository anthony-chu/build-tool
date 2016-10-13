StringValidator(){
	beginsWith(){
		char=${1}
		shift
		string=${@}

		if [[ ${string} == ${char}* ]]; then
			echo true
		else
			return;
		fi
	}

	beginsWithVowel(){
		string=${@}

		case ${string} in
			a*|e*|i*|o*|u*|A*|E*|I*|O*|U*) echo true;;
			*) return
		esac
	}

	isAlpha(){
		local str=${@}

		isNull ${str//[a-zA-Z ]/}
	}

	isAlphaNum(){
		local str=${@}

		isNull ${str//[0-9a-zA-Z ]/}
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

	isOption(){
		local opt=${1}

		if [[ $(isSubstring ${opt} -) ]] && [[ $(isAlphaNum ${opt//-/}) ]]; then
			echo true
		else
			return
		fi
	}

	$@
}