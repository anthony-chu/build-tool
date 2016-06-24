source String/Util/StringUtil.sh

ArrayUtil(){
	appendArrayEntry(){
		local array=($@)
		local maxLength=$(returnMaxLength ${array[@]})
		local newArray=()
		local placeholder=.

		for (( i=0; i<${#array[@]}; i++ )); do
			arrayEntry=${array[i]}

			while [ ${#arrayEntry} -lt ${maxLength} ]; do
				arrayEntry=${arrayEntry}${placeholder}
			done

			newArray+=(${arrayEntry})
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

		for (( i=0; i<${#array[@]}; i++ )); do
			if [[ ${#array[i]} > ${maxLength} ]]; then
				maxLength=${#array[i]}
			fi
		done

		echo ${maxLength}
	}

	$@
}