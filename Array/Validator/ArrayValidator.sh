include Array/Util/ArrayUtil.sh
include Comparator/Comparator.sh

ArrayValidator(){
	hasEntry(){
		local flip=($(ArrayUtil flipArray $@))

		entry=${flip[0]}
		array=(${flip[@]:1})

		for a in ${array[@]}; do
			if [[ $(Comparator isEqual ${a} ${entry}) ]]; then
				echo true
				break
			fi
		done
	}

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