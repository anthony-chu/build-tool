source Base/BaseUtil.sh
source String/StringUtil.sh

MessageBuilderUtil(){
	local time=$(BaseUtil timestamp)

	buildMessage(){
		echo "${time} [$(StringUtil toUpperCase ${1})] $(StringUtil replace $2 - space)"
	}

	$@
}