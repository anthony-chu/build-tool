source Message/MessageBuilderUtil.sh

MessageBuilder(){
	printDone(){
		printInfoMessage DONE
	}

	printErrorMessage(){
		local logLevel=error
		local message=$@

		_buildMessage ${message}
	}

	printInfoMessage(){
		local logLevel=info
		local message=$@

		_buildMessage ${message}
	}

	$@
}