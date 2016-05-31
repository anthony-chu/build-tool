source Message/MessageBuilderUtil.sh

MessageBuilder(){
	local MBUtil(){
		MessageBuilderUtil $@
	}

	printDone(){
		printInfoMessage Done.
	}

	printErrorMessage(){
		MBUtil buildMessage error $1
	}

	printInfoMessage(){
		MBUtil buildMessage info $1
	}

	$@
}