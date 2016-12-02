source bash-toolbox/init.sh

include base.comparator.BaseComparator
include logger.Logger
include string.util.StringUtil
include string.validator.StringValidator
include test.util.TestUtil

include test.AppServerValidatorTest
include test.AppServerVersionConstantsTest
include test.AppServerVersionTest
include test.ArrayUtilTest
include test.ArrayValidatorTest
include test.BaseComparatorTest
include test.BaseVarsTest
include test.LoggerUtilTest
include test.MathUtilTest
include test.StringUtilTest
include test.StringValidatorTest

run-unit-tests(){

	execute-tests(){
		tests=(
			AppServerValidatorTest
			AppServerVersionConstantsTest
			AppServerVersionTest
			ArrayUtilTest
			ArrayValidatorTest
			BaseComparatorTest
			BaseVarsTest
			LoggerUtilTest
			MathUtilTest
			StringUtilTest
			StringValidatorTest
		)

		for group in ${tests[@]}; do
			${group} run
		done
	}

	Logger logProgressMsg "running_all_unit_tests"

	failures=($(execute-tests))

	if [[ ${failures} ]]; then
		Logger logErrorMsg "$(StringUtil toUpperCase some_tests_failed)"

		for failure in ${failures[@]}; do
			echo ${failure}
		done
	else
		TestUtil logSuccessMsg $(StringUtil toUpperCase all_tests_passed)
	fi
}

if [[ $(StringValidator isNull ${1}) ]]; then
	Logger logErrorMsg "please_provide_a_command_to_execute"
elif [[ $(BaseComparator isEqual ${1} run-unit-tests) ]]; then
	${1}
else
	Logger logErrorMsg "${1}_is_not_a_valid_command"
fi