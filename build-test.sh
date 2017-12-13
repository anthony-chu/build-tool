source bash-toolbox/init.sh

include app.server.validator.test.AppServerValidatorTest
include app.server.version.constants.test.AppServerVersionConstantsTest
include app.server.version.test.AppServerVersionTest

include array.util.test.ArrayUtilTest
include array.validator.test.ArrayValidatorTest

include base.comparator.BaseComparator
include base.comparator.test.BaseComparatorTest
include base.vars.test.BaseVarsTest

include file.name.util.test.FileNameUtilTest
include file.util.Test.FileUtilTest
include file.writer.test.FileWriterTest

include help.message.HelpMessage

include language.util.test.LanguageUtilTest

include logger.Logger
include logger.util.test.LoggerUtilTest

include math.util.test.MathUtilTest

include props.reader.util.test.PropsReaderUtilTest
include props.util.test.PropsUtilTest
include props.writer.util.test.PropsWriterUtilTest

include string.util.test.StringUtilTest
include string.validator.StringValidator
include string.validator.test.StringValidatorTest

include system.test.SystemTest

@description runs_all_unit_tests_in_/test_directory
run-unit-tests(){
	Logger logProgressMsg "running_all_unit_tests"

	local tests=(
		AppServerValidatorTest
		AppServerVersionConstantsTest
		AppServerVersionTest
		ArrayUtilTest
		ArrayValidatorTest
		BaseComparatorTest
		BaseVarsTest
		FileNameUtilTest
		FileUtilTest
		FileWriterTest
		LanguageUtilTest
		LoggerUtilTest
		MathUtilTest
		PropsReaderUtilTest
		PropsUtilTest
		PropsWriterUtilTest
		StringUtilTest
		StringValidatorTest
		SystemTest
	)

	if [[ -e results.txt ]]; then
		rm results.txt
	fi

	for group in ${tests[@]}; do
		${group} run |& tee -a results.txt
	done

	Logger logCompletedMsg
}

main(){
	if [[ $(StringValidator isNull ${1}) ]]; then
		HelpMessage printHelpMessage
	elif [[ $(BaseComparator isEqual ${1} run-unit-tests) ]]; then
		${1}
	else
		Logger logErrorMsg "${1}_is_not_a_valid_command"
	fi
}

main $@