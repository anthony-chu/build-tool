BaseFileUtil(){

	getFileStatus(){
		if [[ $(ls | grep ${1}) == "" ]]; then
			echo false
		else
			if [[ $(ls | grep ${1}) == ${1} ]]; then
				echo true
			else
				echo false
			fi
		fi
	}

	$@
}