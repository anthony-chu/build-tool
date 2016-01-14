_maxLength(){
	maxLength=0
	array=${1//\"/}
    array=(${array//[()]/""})

	for (( i=0; i<${#array[@]}; i++ )); do
		if [[ ${#array[i]} > $maxLength ]]; then
			maxLength=${#array[i]}
		else
			maxLength=${maxLength}
		fi
	done

	export maxLength=$maxLength
}

_placeholder(){
    array=${1//\"/}
    array=(${array//[()]/""})
    maxLength=$maxLength
    newArray=""

    for (( i=0; i<${#array[@]}; i++ )); do
		arrayElement=${array[i]}
		placeholder="."

		while [ ${#arrayElement} -lt $maxLength ]; do
			arrayElement="${arrayElement}${placeholder}"
		done

		newArray="${newArray} \"${arrayElement}\""
	done

    export newArray="(${newArray})"
}