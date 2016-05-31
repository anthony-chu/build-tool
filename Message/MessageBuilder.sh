source Message/MessageBuilderUtil.sh

MessageBuilder(){
	local MBUtil(){
		MessageBuilderUtil $@
	}

	printDone(){
		printInfoMessage DONE
	}

	printErrorMessage(){
		MBUtil buildMessage error $1
	}

	printInfoMessage(){
		MBUtil buildMessage info $1
	}

	$@
}