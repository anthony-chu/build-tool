include Base/Util/BaseUtil.sh
include String/Util/StringUtil.sh

MessageBuilderUtil(){
	local time=$(BaseUtil timestamp)

	buildMessage(){
		echo "${time} [$(StringUtil toUpperCase ${1})] $(StringUtil
			replace $(StringUtil capitalize ${2}) - space)"
	}

	$@
}