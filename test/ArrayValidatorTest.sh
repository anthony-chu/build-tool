include array/validator/ArrayValidator.sh
include test/executor/TestExecutor.sh

ArrayValidatorTest(){
	run(){
		local tests=(
			hasEntry[false]
			hasEntry[true]
			hasUniqueEntry[false]
			hasUniqueEntry[true]
		)

		TestExecutor executeTest ArrayValidatorTest ${tests[@]}
	}

	test.hasEntry[false](){
		local inputArray=(foo foo)

		if [[ $(ArrayValidator hasEntry ${inputArray[@]} bar) ]]; then
			echo FAIL
		else
			echo PASS
		fi
	}

	test.hasEntry[true](){
		local inputArray=(foo bar)

		if [[ $(ArrayValidator hasEntry ${inputArray[@]} foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.hasUniqueEntry[false](){
		local inputArray=(foo foo bar)

		if [[ $(ArrayValidator hasUniqueEntry ${inputArray[@]} foo) ]]; then
			echo FAIL
		else
			echo PASS
		fi
	}

	test.hasUniqueEntry[true](){
		local inputArray=(foo foo bar)

		if [[ $(ArrayValidator hasUniqueEntry ${inputArray[@]} bar) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}