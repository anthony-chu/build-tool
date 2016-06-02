FormatterUtil(){
	getExcludeStatus(){
		if [[ ${1} =~ ${2} ]]; then
			isExcluded=true
		else
			isExcluded=false
		fi

		echo ${isExcluded}
	}

	$@
}