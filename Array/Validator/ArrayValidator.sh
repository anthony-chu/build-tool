ArrayValidator(){
	hasUniqueEntry(){
		local tempArray=($(flipArray $@))

		entry=${tempArray[0]}
		array=(${tempArray[@]/${entry}/})

		if [[ "${array[@]}" == *${entry}* ]]; then
			echo false
		else
			echo true
		fi
	}

	$@
}