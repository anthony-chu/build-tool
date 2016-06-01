source Message/MessageBuilderUtil.sh

MessageBuilder(){
	MBUtil(){
		MessageBuilderUtil $@
	}

	printDone(){
		printInfoMessage Done.
	}

	printErrorMessage(){
		MBUtil buildMessage error ${1}
	}

	printInfoMessage(){
		MBUtil buildMessage info ${1}
	}

	printProgressMessage(){
		MBUtil printInfoMessage ${1}...
	}

	$@
}