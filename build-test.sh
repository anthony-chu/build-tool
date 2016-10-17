source ${projectDir}.init.sh

include base.comparator.BaseComparator
include logger.Logger
include string.validator.StringValidator

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
}

if [[ $(StringValidator isNull ${1}) ]]; then
	Logger logErrorMsg please_provide_a_command_to_execute
elif [[ $(BaseComparator isEqual ${1} run-unit-tests) ]]; then
	${1}
else
	Logger logErrorMsg ${1}_is_not_a_valid_command
fi