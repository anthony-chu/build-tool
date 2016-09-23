include base.util.BaseUtil
include string.util.StringUtil

LoggerUtil(){
	local time=$(BaseUtil timestamp log)

	getLogMsg(){
		echo "[${time}] [ $(StringUtil toUpperCase ${1}) ] $(StringUtil
			replace $(StringUtil capitalize ${2}) - space)"
	}

	$@
}