include array.util.ArrayUtil
include test.executor.TestExecutor

ArrayUtilTest(){
	run(){
		local tests=(
			appendArrayEntry
			convertStringToArray
			flipArray
			returnMaxLength
			strip
		)

		TestExecutor executeTest ArrayUtilTest ${tests[@]}
	}

	test.appendArrayEntry(){
		local inputArray=(foo foobar)
		local outputArray=(foo... foobar)

		if [[ $(ArrayUtil appendArrayEntry ${inputArray[@]}) == ${outputArray[@]} ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.convertStringToArray(){
		local input="foo,bar"
		local output="foo bar"

		if [[ $(ArrayUtil convertStringToArray ${input}) == ${output} ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.flipArray(){
		local inputArray=(foo bar)
		local outputArray=(bar foo)

		if [[ $(ArrayUtil flipArray ${inputArray[@]}) == ${outputArray[@]} ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.returnMaxLength(){
		local inputArray=(foo foobar)
		local maxLength=6

		if [[ $(ArrayUtil returnMaxLength ${inputArray[@]}) == ${maxLength} ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.strip(){
		local inputArray=(foo foo bar bar)

		if [[ $(ArrayUtil strip ${inputArray[@]} foo) == "bar bar" ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}