include String/Validator/StringValidator.sh

StringValidatorTest(){
	run(){
		tests=(
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

	test.isAlpha[false](){
		if [[ $(StringValidator isAlpha 123) ]]; then
			echo FAIL
		else
			echo PASS
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
		if [[ $(StringValidator isAlphaNum abc_) ]]; then
			echo FAIL
		else
			echo PASS
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
		if [[ $(StringValidator isSubstring foobar this) ]]; then
			echo FAIL
		else
			echo PASS
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
		if [[ $(StringValidator isNull foo) ]]; then
			echo FAIL
		else
			echo PASS
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
		if [[ $(StringValidator isNum abc) ]]; then
			echo FAIL
		else
			echo PASS
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
		}
		fi

	${@}
}