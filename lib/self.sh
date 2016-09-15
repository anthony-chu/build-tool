self(){
	call(){
		thisFile=${0//.sh/}
		thisFile=${thisFile//*\//}

		if [[ ${1} == ${thisFile} ]]; then
			${1}
		fi
	}

	$@
}