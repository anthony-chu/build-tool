source String/StringValidator.sh

FormatterUtil(){
	getExcludeStatus(){
		isSubstring=$(StringValidator isSubstring ${1} ${2})
		if [[ ${isSubstring} == true ]]; then
			isExcluded=true
		else
			isExcluded=false
		fi

		echo ${isExcluded}
	}

	$@
}