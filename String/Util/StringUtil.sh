include Comparator/Comparator.sh
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

		if [[ $(Comparator isEqual ${orig} space) ]]; then
			orig=" "
		fi

		if [[ $(Comparator isEqual ${new} space) ]]; then
			new=" "
		fi

		echo ${str//${orig}/${new}}
	}

	returnOption(){
		local opt=${1}

		if [[ $(StringValidator isSubstring ${opt} -) ]]; then
			local isValidOpt=$(StringValidator isAlphaNum ${opt/-/ })
		fi

		if [[ ${isValidOpt} ]]; then
			replace ${opt} -
		fi
	}

	strip(){
		replace ${1} ${2}
	}

	toLowerCase(){
		local str=${1}

		echo ${str,,}
	}

	toUpperCase(){
		local str=${1}

		echo ${str^^}
	}

	$@
}