source bash-toolbox/init.sh

include app.server.validator.test.AppServerValidatorTest
include app.server.version.constants.test.AppServerVersionConstantsTest
include app.server.version.test.AppServerVersionTest

include array.util.test.ArrayUtilTest
include array.validator.test.ArrayValidatorTest

include command.validator.test.CommandValidatorTest

include curl.util.test.CurlUtilTest

include file.name.util.test.FileNameUtilTest
include file.util.test.FileUtilTest
include file.validator.test.FileValidatorTest
include file.writer.test.FileWriterTest

include help.message.HelpMessage

include jira.util.test.JiraUtilTest

include language.util.test.LanguageUtilTest

include logger.Logger
include logger.util.test.LoggerUtilTest

include matcher.test.MatcherTest

include math.util.test.MathUtilTest

include props.reader.util.test.PropsReaderUtilTest
include props.util.test.PropsUtilTest
include props.writer.util.test.PropsWriterUtilTest

include repo.test.RepoTest

include string.util.test.StringUtilTest
include string.validator.StringValidator
include string.validator.test.StringValidatorTest

include system.test.SystemTest

include test.executor.TestExecutor

@description runs_all_unit_tests_in_/test_directory
runUnitTests(){
	${_log} info "running_all_unit_tests..."

	local classes=(
		AppServerValidatorTest
		AppServerVersionConstantsTest
		AppServerVersionTest
		ArrayUtilTest
		ArrayValidatorTest
		CommandValidatorTest
		CurlUtilTest
		FileNameUtilTest
		FileUtilTest
		FileValidatorTest
		FileWriterTest
		JiraUtilTest
		LanguageUtilTest
		LoggerUtilTest
		MatcherTest
		MathUtilTest
		PropsReaderUtilTest
		PropsUtilTest
		PropsWriterUtilTest
		RepoTest
		StringUtilTest
		StringValidatorTest
		SystemTest
	)

	rf -rf results.txt

	for class in ${classes[@]}; do
		TestExecutor executeTest ${class} |& tee -a results.txt
	done

	${_log} info "completed"
}

main(){
	if [[ ! ${1} ]]; then
		HelpMessage printHelpMessage
	elif [[ ${1} == runUnitTests ]]; then
		local _log="Logger log"

		${1}
	else
		Logger logErrorMsg "${1}_is_not_a_valid_command"
	fi
}

main $@