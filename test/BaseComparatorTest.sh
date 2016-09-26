include base.comparator.BaseComparator
include test.executor.TestExecutor

BaseComparatorTest(){
	run(){
		local tests=(
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

		TestExecutor executeTest BaseComparatorTest ${tests[@]}
	}

	test.isEqual[Number](){
		if [[ $(BaseComparator isEqual 123 123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isEqual[String](){
		if [[ $(BaseComparator isEqual foo foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isEqualIgnoreCase(){
		if [[ $(BaseComparator isEqualIgnoreCase FOO foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[Case](){
		if [[ $(BaseComparator isLessThan foo FOO) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[Number](){
		if [[ $(BaseComparator isLessThan 1 2) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isLessThan[String](){
		if [[ $(BaseComparator isLessThan bar foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[Case](){
		if [[ $(BaseComparator isGreaterThan FOO foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[Number](){
		if [[ $(BaseComparator isGreaterThan 2 1) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isGreaterThan[String](){
		if [[ $(BaseComparator isGreaterThan foo bar) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}