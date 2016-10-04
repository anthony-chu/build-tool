include string.validator.stringvalidator
include test.executor.TestExecutor

StringValidatorTest(){
	run(){
		local tests=(
			beginsWithVowel[a]
			beginsWithVowel[A]
			beginsWithVowel[e]
			beginsWithVowel[E]
			beginsWithVowel[false]
			beginsWithVowel[i]
			beginsWithVowel[I]
			beginsWithVowel[null]
			beginsWithVowel[o]
			beginsWithVowel[O]
			beginsWithVowel[u]
			beginsWithVowel[U]
			isAlpha[false]
			isAlpha[space]
			isAlpha[true]
			isAlphaNum[false]
			isAlphaNum[space]
			isAlphaNum[true]
			isSubstring[false]
			isSubstring[true]
			isNull[false]
			isNull[true]
			isNum[false]
			isNum[true]
			isOption[alpha]
			isOption[alphaNum]
			isOption[num]
		)

		TestExecutor executeTest StringValidatorTest ${tests[@]}
	}

	test.beginsWithVowel[a](){
		if [[ $(StringValidator beginsWithVowel alpha) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[A](){
		if [[ $(StringValidator beginsWithVowel Alpha) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[e](){
		if [[ $(StringValidator beginsWithVowel epsilon) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[E](){
		if [[ $(StringValidator beginsWithVowel Epsilon) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[false](){
		if [[ ! $(StringValidator beginsWithVowel beta) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[i](){
		if [[ $(StringValidator beginsWithVowel iota) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[I](){
		if [[ $(StringValidator beginsWithVowel Iota) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[null](){
		if [[ ! $(StringValidator beginsWithVowel) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[o](){
		if [[ $(StringValidator beginsWithVowel omega) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[O](){
		if [[ $(StringValidator beginsWithVowel Omega) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[u](){
		if [[ $(StringValidator beginsWithVowel upsilon) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.beginsWithVowel[U](){
		if [[ $(StringValidator beginsWithVowel Upsilon) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlpha[false](){
		if [[ ! $(StringValidator isAlpha 123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlpha[space](){
		if [[ $(StringValidator isAlpha abc def) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlpha[true](){
		if [[ $(StringValidator isAlpha abc) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlphaNum[false](){
		if [[ ! $(StringValidator isAlphaNum abc_) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlphaNum[space](){
		if [[ $(StringValidator isAlphaNum abc 123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isAlphaNum[true](){
		if [[ $(StringValidator isAlphaNum abc123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isSubstring[false](){
		if [[ ! $(StringValidator isSubstring foobar this) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isSubstring[true](){
		if [[ $(StringValidator isSubstring foobar foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isNull[false](){
		if [[ ! $(StringValidator isNull foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isNull[true](){
		if [[ $(StringValidator isNull) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isNum[false](){
		if [[ ! $(StringValidator isNum abc) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isNum[true](){
		if [[ $(StringValidator isNum 123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isOption[alpha](){
		if [[ $(StringValidator isOption -foo) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isOption[alphaNum](){
		if [[ $(StringValidator isOption -foo123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test.isOption[num](){
		if [[ $(StringValidator isOption -123) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	${@}
}