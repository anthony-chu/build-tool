TestExecutor(){
	executeTest(){
		group=${1}
		shift
		tests=(${@})

		for test in ${tests[@]}; do
			if [[ $(${group} test.${test}) == FAIL ]]; then
				echo ${group}_test.${test}
			fi
		done
	}

	${@}
}