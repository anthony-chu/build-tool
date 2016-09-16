source ${projectDir}.init.sh

package test

run-unit-tests(){
	tests=(
		AppServerValidatorTest
		AppServerVersionConstantsTest
		ArrayUtilTest
		ArrayValidatorTest
		ComparatorTest
		StringUtilTest
		StringValidatorTest
	)

	for group in ${tests[@]}; do
		${group} run
	done
}

if [[ ${1} == run-unit-tests ]]; then
	${1}
fi