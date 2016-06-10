source String/Validator/StringValidator.sh

FormatterUtil(){
	getExcludeStatus(){
		isSubstring=$(StringValidator isSubstring ${1} ${2})

		echo ${isSubstring}
	}

	$@
}