include message.builder.helper.MessageBuilderHelper

MessageBuilder(){
	local MBHelper="MessageBuilderHelper"

	logCompletedMsg(){
		logInfoMsg Completed.
	}

	logErrorMsg(){
		${MBHelper} buildMessage error ${1}
	}

	logInfoMsg(){
		${MBHelper} buildMessage info ${1}
	}

	logProgressMsg(){
		${MBHelper} logInfoMsg ${1}...
	}

	$@
}