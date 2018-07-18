source bash-toolbox/init.sh

include logger.Logger

include string.util.StringUtil

main(){
	local _log="Logger log"

	local _className=${1}
	local _cmd=${2}
	shift 2
	local args=$@

	if [[ ! ${_className} ]]; then
		${_log} error "please_provide_a_classname_and_command."
		exit
	fi

	local className=($(echo ${_className} |	sed "s#\([A-Z]\)#\ \L\1#g"))

	include $(StringUtil replace className space .).${_className}

	${_className} ${_cmd} ${args}
}

main ${@}