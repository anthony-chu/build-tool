Comparator(){
	isEqual(){
		if [[ ${1} == ${2} ]]; then
			echo true
		else
			return;
		fi
	}

	isEqualIgnoreCase(){
		x=${1}
		y=${2}
		isEqual ${x,,} ${y,,}
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