TestExecutor(){
	executeTest(){
		local group=${1}
		shift
		local tests=(${@})

		for test in ${tests[@]}; do
			if [[ $(${group} test.${test}) == FAIL ]]; then
				echo ${group}_test.${test}
			fi
		done
	}

	${@}
}