source bash-toolbox/init.sh

include base.comparator.BaseComparator

include finder.Finder

include formatter.Formatter

include help.message.HelpMessage

include logger.Logger

include string.util.StringUtil
include string.validator.StringValidator

main(){
	Logger logProgressMsg "validating_formatting_rules"

	files=($(Finder findBySubstring sh))

	tasks=(
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

if [[ ! $(StringValidator isNull ${1}) ]]; then
	if [[ $(BaseComparator isEqual $(StringUtil returnOption ${1}) h) || $(
		BaseComparator isEqual $(StringUtil returnOption ${1}) help) ]]; then

		HelpMessage formatHelpMessage
	fi
else
	main
fi