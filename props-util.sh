source bash-toolbox/init.sh

package props

include logger.Logger

include string.util.StringUtil
include string.validator.StringValidator

main(){
	if [[ ! $(StringValidator isNull ${1}) ]]; then
		case ${1} in
			read|set|unset) local _cmd=${1} ;;
			*) Logger logErrorMsg "\"${1}\"_is_not_a_valid_command" && exit ;;
		esac

		shift

		case $(StringUtil returnOption ${1}) in
			a) local propsType=AppServer;;
			b) local propsType=Build;;
			p) local propsType=Portal;;
			t) local propsType=Test;;
		esac

		local cmd=${_cmd}${propsType}Props

		shift

		local branch=${1}

		shift

		if [[ $(StringValidator isSubstring _cmd "set") ]]; then
			local className=PropsWriter
		else
			local className=PropsReader
		fi

		${className} ${cmd} ${branch} $@
	fi
}

main $@