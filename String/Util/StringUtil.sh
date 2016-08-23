include String/Validator/StringValidator.sh

StringUtil(){
	capitalize(){
		local str=${1}

		echo ${str^}
	}

	replace(){
		local str=${1}
		local orig=${2}
		local new=${3}

		if [[ ${new} == space ]]; then
			new=" "
		fi

		echo ${str//${orig}/${new}}
	}

	returnOption(){
		local opt=${1}

		if [[ $(StringValidator isSubstring ${opt} -) ]]; then
			isValidOpt=$(StringValidator isAlphaNum ${opt/-/ })
		fi

		if [[ ${isValidOpt} ]]; then
			$(replace ${opt} -)
		fi
	}

	toLowerCase(){
		str=${1}

		echo ${str,,}
	}

	toUpperCase(){
		str=${1}

		echo ${str^^}
	}

	$@
}