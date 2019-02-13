#!/usr/bin/env bash

source bash-toolbox/init.sh

include logger.Logger

include props.reader.PropsReader
include props.writer.PropsWriter

include string.util.StringUtil

main(){
	local _log="Logger log"

	if [[ ${1} ]]; then
		case ${1} in
			read|set|unset) local _cmd=${1} ;;
			*) ${_log} error "\"${1}\"_is_not_a_valid_command" && exit ;;
		esac

		shift

		case $(StringUtil returnOption ${1}) in
			a) local propsType=AppServer;;
			b) local propsType=Build;;
			p) local propsType=Portal;;
			t) local propsType=Test;;
		esac

		local cmd=${_cmd}${propsType}Props

		shift

		local branch=${1}

		shift

		if [[ ${_cmd} =~ "set") ]]; then
			local className=PropsWriter
		else
			local className=PropsReader
		fi

		${className} ${cmd} ${branch} $@
	fi
}

main $@