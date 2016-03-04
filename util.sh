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
	_strToArray "$1"
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

_nullValidator(){
	local string=$1

	if [[ $string ]]; then
		echo false
	else
		echo true
	fi
}

_placeholder(){
    _strToArray "$1"
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

_stringReplace(){
	str=$1
	orig=$2
	new=$3

	export newStr=${str//$orig/$new}
}

_strToArray(){
	str=$1

	array=${str//\"/}
    array=(${array//[()]/""})

	export array=${array[@]}
}

_stringValidator(){
	local str1=$1
	local str2=$1

	if [[ $1 == $2 ]]; then
		echo true
	else
		echo false
	fi
}

gitpr(){
	alias gitpr="source d:/git-tools/git-pull-request/git-pull-request.sh"
	source "c:/users/liferay/.bashrc"
	source "d:/git-tools/git-pull-request/git-pull-request.sh"
}

getOption(){
	if [[ $1 == -[a-zA-Z0-9]* ]]; then
		echo ${1/-/ }
	fi
}