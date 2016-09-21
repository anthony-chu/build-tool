include base.util.BaseUtil
include string.util.StringUtil

MessageBuilderHelper(){
	local time=$(BaseUtil timestamp log)

	buildMessage(){
		echo "[${time}] [ $(StringUtil toUpperCase ${1}) ] $(StringUtil
			replace $(StringUtil capitalize ${2}) - space)"
	}

	$@
}