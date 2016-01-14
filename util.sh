_arrayToStr(){
	array=($@)

	arrayString=""
	for (( i=0; i<${#array[@]}; i++ )); do
		if [[ $i == 0 ]]; then
			arrayString="\"${array[i]}\""
		else
			arrayString="${arrayString} \"${array[i]}\""
		fi
	done

	export arrayString="(${arrayString})"
}

_maxLength(){
	maxLength=0
	_stringToArray "$1"
	array=($array)

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
    _stringToArray "$1"
	array=($array)
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

_stringToArray(){
	str=$1

	array=${str//\"/}
    array=(${array//[()]/""})

	export array=${array[@]}
}