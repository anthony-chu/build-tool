include string.util.StringUtil
include test.executor.TestExecutor

StringUtilTest(){
	run(){
		local tests=(
			capitalize
			length
			replace[space]
			replace
			returnOption[false]
			returnOption[true]
			toLowerCase
			toUpperCase
		)

		TestExecutor executeTest StringUtilTest ${tests[@]}
	}

	test.capitalize(){
		if [[ $(StringUtil capitalize foo) == Foo ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.length(){
		if [[ $(StringUtil length foo) == 3 ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.replace(){
		if [[ $(StringUtil replace foo-bar - .) == foo.bar ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.replace[space](){
		if [[ $(StringUtil replace foo-bar - space) == "foo bar" ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.returnOption[false](){
		if [[ ! $(StringUtil returnOption foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.returnOption[true](){
		if [[ $(StringUtil returnOption -foo) == foo ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.toLowerCase(){
		if [[ $(StringUtil toLowerCase FOO) == foo ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.toUpperCase(){
		if [[ $(StringUtil toUpperCase foo) == FOO ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	${@}
}