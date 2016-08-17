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
		declare isValidOpt

		if [[ $(StringValidator isSubstring ${opt} -) ]]; then
			isValidOpt=$(StringValidator isAlphaNum ${opt/-/ })
		fi

		if [[ ${isValidOpt} ]]; then
			echo ${opt/-/ }
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