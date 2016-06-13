source Base/Util/BaseUtil.sh
source String/Util/StringUtil.sh

MessageBuilderUtil(){
	local time=$(BaseUtil timestamp)

	buildMessage(){
		_message=$(StringUtil capitalize ${2})

		echo "${time} [$(StringUtil toUpperCase ${1})] $(StringUtil replace ${_message} - space)"
	}

	$@
}