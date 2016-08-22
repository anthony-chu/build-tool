include String/Util/StringUtil.sh

Comparator(){
	isEqual(){
		if [[ ${1} == ${2} ]]; then
			echo true
		else
			return;
		fi
	}

	isEqualIgnoreCase(){
		isEqual $(StringUtil toLowerCase ${1}) $(StringUtil toLowerCase ${2})
	}

	isLessThan(){
		if [[ ${1} < ${2} ]]; then
			echo true
		else
			return;
		fi
	}

	isGreaterThan(){
		if [[ ${1} > ${2} ]]; then
			echo true
		else
			return;
		fi
	}

	$@
}