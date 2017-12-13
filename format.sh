source bash-toolbox/init.sh

include base.comparator.BaseComparator

include formatter.Formatter

include logger.Logger

include props.reader.util.PropsReaderUtil

include string.util.StringUtil
include string.validator.StringValidator

_main(){
	Logger logProgressMsg "validating_formatting_rules"

	local skipVariableValidation=$(PropsReaderUtil
		readProps $(pwd)/formatter.properties ignore_local_variables)
	local files=($(find * -type f -iname "*.sh"))

	local tasks=(
		applyUnixLineEndings
		convertSpacesToTabs
		enforceBashToolboxLocalVariables
		enforceLoggerMessageQuotes
		verifyCharacterLimitPerLine
		verifyNoIncludesInBase
	)

	for file in ${files[@]}; do
		for task in ${tasks[@]}; do
			if [[ ${task} == enforceLocalVariables &&
				! ${skipVariableValidation} =~ ${file} ]]; then

				Formatter ${task} ${file}
			else
				Formatter ${task} ${file}
			fi
		done
	done

	Logger logCompletedMsg
}

_main