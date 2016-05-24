source Base/BaseUtil.sh

MessageBuilder(){
	local time=$(BaseUtil timestamp)

	_buildMessage(){
		local message=$@

		echo "$time [${logLevel^^}] $message."
	}

	printDone(){
		printInfoMessage DONE
	}

	printErrorMessage(){
		local logLevel=error
		local message=$@

		_buildMessage $message
	}

	printInfoMessage(){
		local logLevel=info
		local message=$@

		_buildMessage $message
	}

	$@
}