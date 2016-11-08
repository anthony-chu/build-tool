source ${projectDir}.init.sh

include base.comparator.BaseComparator
include logger.Logger

package string
package test

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
			StringUtilTest
			StringValidatorTest
		)

		for group in ${tests[@]}; do
			${group} run
		done
	}

	Logger logProgressMsg "running_all_unit_tests"

	if [[ $(execute-tests) ]]; then
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