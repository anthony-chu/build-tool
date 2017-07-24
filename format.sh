source bash-toolbox/init.sh

include base.comparator.BaseComparator

include formatter.Formatter

include logger.Logger

include string.util.StringUtil
include string.validator.StringValidator

_main(){
	Logger logProgressMsg "validating_formatting_rules"

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
			Formatter ${task} ${file}
		done
	done

	Logger logCompletedMsg
}

_main