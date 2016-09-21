include message.builder.util.MessageBuilderHelper

MessageBuilder(){
	local MBUtil="MessageBuilderHelper"

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