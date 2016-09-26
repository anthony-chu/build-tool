include base.util.BaseUtil
include string.util.StringUtil

LoggerUtil(){
	getLogMsg(){
		local time=$(BaseUtil timestamp log)

		echo "[${time}] [ $(StringUtil toUpperCase ${1}) ] $(StringUtil
			replace $(StringUtil capitalize ${2}) - space)"
	}

	$@
}