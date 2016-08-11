source ${projectDir}Array/Util/ArrayUtil.sh

ArrayValidator(){
	hasUniqueEntry(){
		local tempArray=($(ArrayUtil flipArray $@))

		entry=${tempArray[0]}
		array=(${tempArray[@]/${entry}/})

		if [[ "${array[@]}" == *${entry}* ]]; then
			return;
		else
			echo true
		fi
	}

	$@
}