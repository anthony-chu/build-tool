Comparator(){
	isEqual(){
		if [[ $1 == $2 ]]; then
			echo true
		else
			return;
		fi
	}

	isLessThan(){
		if [[ $1 < $2 ]]; then
			echo true
		else
			return;
		fi
	}

	isGreaterThan(){
		if [[ $1 > $2 ]]; then
			echo true
		else
			return;
		fi
	}

	$@
}