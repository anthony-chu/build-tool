include array.util.ArrayUtil
include comparator.Comparator

ArrayValidator(){
	hasEntry(){
		local _flip=($(ArrayUtil flipArray $@))

		local entry=${_flip[0]}
		local array=(${_flip[@]:1})

		for a in ${array[@]}; do
			if [[ $(Comparator isEqual ${a} ${entry}) ]]; then
				echo true
				break
			fi
		done
	}

	hasUniqueEntry(){
		local _flip=($(ArrayUtil flipArray $@))

		local entry=${_flip[0]}
		local array=(${_flip[@]:1})

		if [[ $(hasEntry ${array[@]} ${entry}) ]]; then
			local count=0

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