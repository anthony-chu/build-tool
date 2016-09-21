include message.builder.util.MessageBuilderUtil

MessageBuilder(){
	local MBUtil="MessageBuilderUtil"

	printDone(){
		printInfoMessage Done.
	}

	printErrorMessage(){
		${MBUtil} buildMessage error ${1}
	}

	printInfoMessage(){
		${MBUtil} buildMessage info ${1}
	}

	printProgressMessage(){
		${MBUtil} printInfoMessage ${1}...
	}

	$@
}