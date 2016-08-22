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
		local flip=($(ArrayUtil flipArray $@))

		entry=${flip[0]}
		array=(${flip[@]:1})

		if [[ $(hasEntry ${array[@]} ${entry}) ]]; then
			count=0

			for a in ${array[@]}; do
				if [[ $(Comparator isEqual ${a} ${entry}) ]]; then
					count=$((count+1))
				fi
			done

			if [[ $(Comparator isGreaterThan ${count} 1) ]]; then
				return
			else
				echo true
			fi
		else
			return
		fi
	}

	$@
}