include Comparator/Comparator.sh
include Test/Executor/TestExecutor.sh

ComparatorTest(){
	run(){
		tests=(
			isEqual[Number]
			isEqual[String]
			isEqualIgnoreCase
			isLessThan[Case]
			isLessThan[Number]
			isLessThan[String]
			isGreaterThan[Case]
			isGreaterThan[Number]
			isGreaterThan[String]
		)

		TestExecutor executeTest ComparatorTest ${tests[@]}
	}

	test.isEqual[Number](){
		if [[ $(Comparator isEqual 123 123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isEqual[String](){
		if [[ $(Comparator isEqual foo foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isEqualIgnoreCase(){
		if [[ $(Comparator isEqualIgnoreCase FOO foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[Case](){
		if [[ $(Comparator isLessThan foo FOO) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[Number](){
		if [[ $(Comparator isLessThan 1 2) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[String](){
		if [[ $(Comparator isLessThan bar foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[Case](){
		if [[ $(Comparator isGreaterThan FOO foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[Number](){
		if [[ $(Comparator isGreaterThan 2 1) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[String](){
		if [[ $(Comparator isGreaterThan foo bar) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}