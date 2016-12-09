source bash-toolbox/init.sh

include finder.Finder

include logger.Logger

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
		Format ${task} ${file}
	done
done

Logger logCompletedMsg