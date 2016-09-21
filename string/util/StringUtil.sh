include base.comparator.BaseComparator
include string.validator.Stringvalidator

StringUtil(){
	capitalize(){
		local str=${@}

		echo ${str^}
	}

	replace(){
		local str=${1}
		local orig=${2}
		local new=${3}

		if [[ $(BaseComparator isEqual ${orig} space) ]]; then
			orig=" "
		fi

		if [[ $(BaseComparator isEqual ${new} space) ]]; then
			new=" "
		fi

		echo ${str//${orig}/${new}}
	}

	returnOption(){
		local opt=${1}

		if [[ $(StringValidator isSubstring ${opt} -) ]]; then
			local isValidOpt=$(StringValidator isAlphaNum $(strip ${opt} -))
		fi

		if [[ ${isValidOpt} ]]; then
			strip ${opt} -
		fi
	}

	strip(){
		replace ${1} ${2}
	}

	toLowerCase(){
		local str=${@}

		echo ${str,,}
	}

	toUpperCase(){
		local str=${@}

		echo ${str^^}
	}

	$@
}