source bash-toolbox/init.sh

include logger.Logger

include string.util.StringUtil

main(){
	local _className=${1}
	local _cmd=${2}
	shift 2
	local args=$@

	if [[ ! ${1} ]]; then
		Logger logErrorMsg "please_provide_a_classname_and_command."
		exit
	fi

	local className=($(echo ${_className} |  sed "s#\([A-Z]\)#\ \L\1#g"))

	include $(StringUtil replace className space .).${_className}

	${_className} ${_cmd} ${args}
}

main ${@}