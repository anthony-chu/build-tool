include array.util.ArrayUtil
include base.comparator.BaseComparator
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

		if [[ $(BaseComparator isEqualIgnoreCase ${1} error) ]]; then
			message="\033[0;31m$(StringUtil replace $(StringUtil
				capitalize ${2}) _ space)\033[0m"
		else
			message=$(StringUtil replace $(StringUtil capitalize ${2}) _ space)
		fi

		echo -e "[${time}] [ $(_formatLogLevel ${1}) ] ${message}"
	}

	$@
}