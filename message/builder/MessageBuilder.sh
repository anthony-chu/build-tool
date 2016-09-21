include message.builder.util.MessageBuilderHelper

MessageBuilder(){
	local MBHelper="MessageBuilderHelper"

	printDone(){
		printInfoMessage Done.
	}

	printErrorMessage(){
		${MBHelper} buildMessage error ${1}
	}

	printInfoMessage(){
		${MBHelper} buildMessage info ${1}
	}

	printProgressMessage(){
		${MBHelper} printInfoMessage ${1}...
	}

	$@
}