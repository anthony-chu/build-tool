#!/usr/bin/env bash

source bash-toolbox/init.sh

include command.validator.CommandValidator

include formatter.Formatter

include logger.Logger

include props.reader.util.PropsReaderUtil

include string.util.StringUtil

_main(){
	local _log="Logger log"

	_log info "validating_formatting_rules..."

	local files=($(find * -type f -iname "*.sh"))
	local skipVariableValidation=$(PropsReaderUtil
		readProps $(pwd)/formatter.properties ignore_local_variables)
	local tasks=($(CommandValidator
		getValidFunctions bash-toolbox/formatter/Formatter.sh))

	for file in ${files[@]}; do
		for task in $(StringUtil strip tasks Formatter); do
			if [[ ${task} == enforceLocalVariables &&
				${skipVariableValidation} =~ ${file} ]]; then

				continue
			else
				Formatter ${task} ${file}
			fi
		done
	done

	${_log} info "completed"
}

_main