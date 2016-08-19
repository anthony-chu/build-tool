include(){
	source ${projectDir}${1}
}

if [[ ${1} == include ]]; then
	${@}
fi