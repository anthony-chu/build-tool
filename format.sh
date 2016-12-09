source bash-toolbox/init.sh

include finder.Finder

include formatter.Formatter

include logger.Logger

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

main