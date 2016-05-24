ArrayUtil(){
	appendArrayEntry(){
		local array=($@)
		local maxLength=$(returnMaxLength ${array[@]})
		local newArray=()
		local placeholder=.

		for (( i=0; i<${#array[@]}; i++ )); do
			arrayEntry=${array[i]}

			while [ ${#arrayEntry} -lt $maxLength ]; do
				arrayEntry=${arrayEntry}${placeholder}
			done

			newArray+=(${arrayEntry})
		done

		echo ${newArray[@]}
	}

	returnMaxLength(){
		local array=($@)
		local maxLength=0

		for (( i=0; i<${#array[@]}; i++ )); do
			if [[ ${#array[i]} > $maxLength ]]; then
				maxLength=${#array[i]}
			fi
		done

		echo $maxLength
	}

	$@
}