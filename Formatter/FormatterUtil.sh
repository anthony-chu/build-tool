FormatterUtil(){
	getExcludeStatus(){
		if [[ ${1} =~ ${2} ]]; then
			isExcluded=true
			break
		else
			isExcluded=false
		fi

		echo ${isExcluded}
	}

	$@
}