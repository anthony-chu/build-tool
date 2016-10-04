include base.comparator.BaseComparator
include string.validator.StringValidator

StringUtil(){
	capitalize(){
		local str=${@}

		echo ${str^}
	}

	length(){
		str=${@}

		echo ${#str}
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
		local isValidOpt=$(StringValidator isOption ${1})

		if [[ ${isValidOpt} ]]; then
			strip ${1} -
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