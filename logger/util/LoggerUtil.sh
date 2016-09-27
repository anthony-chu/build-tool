include array.util.ArrayUtil
include base.util.BaseUtil
include string.util.StringUtil

LoggerUtil(){
	_formatLogLevel(){
		logLevel=${1}
		validLogLevels=(info error)

		maxLength=$(ArrayUtil returnMaxLength ${validLogLevels[@]})

		while [[ $(BaseComparator isLessThan $(StringUtil
			length ${logLevel}) ${maxLength}) ]]; do
			logLevel+=_
		done

		StringUtil toUpperCase ${logLevel}
	}

	getLogMsg(){
		local time=$(BaseUtil timestamp log)

		echo "[${time}] [ $(_formatLogLevel ${1}) ] $(StringUtil
			replace $(StringUtil capitalize ${2}) _ space)"
	}

	$@
}