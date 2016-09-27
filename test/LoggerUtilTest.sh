include base.comparator.BaseComparator
include logger.util.LoggerUtil
include test.executor.TestExecutor

LoggerUtilTest(){
	run(){
		local tests=(
			_formatLogLevel[error]
			_formatLogLevel[info]
		)

		TestExecutor executeTest LoggerUtilTest ${tests[@]}
	}

	test._formatLogLevel[error](){
		if [[ $(BaseComparator isEqual $(LoggerUtil _formatLogLevel error) ERROR) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	test._formatLogLevel[info](){
		if [[ $(BaseComparator isEqual $(LoggerUtil _formatLogLevel info) INFO_) ]]; then
			echo PASS
		else
			echo FAIL
		fi
	}

	$@
}