include string.util.StringUtil

ArrayUtil(){
	appendArrayEntry(){
		local array=($@)
		local maxLength=$(returnMaxLength ${array[@]})
		local newArray=()
		local placeholder=.

		for a in ${array[@]}; do
			while [ ${#a} -lt ${maxLength} ]; do
				a+=${placeholder}
			done

			newArray+=(${a})
		done

		echo ${newArray[@]}
	}

	convertStringToArray(){
		local string=${1}
		StringUtil replace ${string} , space
	}

	flipArray(){
		inputArray=($@)
		newArray=()

		for (( i=${#inputArray[@]}; i>=0; i-- )); do
			newArray+=(${inputArray[i]})
		done

		echo ${newArray[@]}
	}

	returnMaxLength(){
		local array=($@)
		local maxLength=0

		for a in ${array[@]}; do
			if [[ ${#a} > ${maxLength} ]]; then
				maxLength=${#a}
			fi
		done

		echo ${maxLength}
	}

	$@
}