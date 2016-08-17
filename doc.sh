source ${projectDir}lib/include.sh

include Docs/Util/DocsUtil.sh
include Help/Message/HelpMessage.sh
include Message/Builder/MessageBuilder.sh
include String/Validator/StringValidator.sh

listAllMethodsFromSource(){
	sources=($(DocsUtil getSources))

	for (( i=0; i<${#sources[@]}; i++ )); do
		cat ${sources[i]} | grep '[a-z]*(){'
		echo
	done
}

listDependenciesFromSource(){
	file=${1}

	if [[ $(StringValidator isNull ${file}) ]]; then
		MessageBuilder printErrorMessage please-provide-a-file-name-or-class
		exit
	else
		sources=($(DocsUtil getSources))

		for s in ${sources[@]}; do
			if [[ $(StringValidator isSubstring ${s} ${file}) ]]; then
				isValidFile=true
				filePath=${sources[i]}
				break
			else
				isValidFile=false
			fi
		done

		if [[ ${isVaildFile} == false ]]; then
			MessageBuilder printErrorMessage ${file}-does-not-exist.-please-check-your-spelling-or-try-another-file
		elif [[ ${isValidFile} ]]; then
			MessageBuilder printInfoMessage dependencies-for-${file/[.]sh/}
			echo
			cat ${filePath} | grep 'source'
		fi
	fi
}

listMethodsFromSource(){
	file=${1}

	if [[ $(StringValidator isNull ${file}) ]]; then
		MessageBuilder printErrorMessage please-provide-a-file-name-or-class
		exit
	else
		MessageBuilder printInfoMessage available-methods-for-class-${file}
		echo
	fi

	sources=($(DocsUtil getSources))

	for s in ${sources[@]}; do
		if [[ $(StringValidator isSubstring ${s} ${file}) ]]; then
			isValidFile=true
			filePath=${sources[i]}
			break
		else
			isValidFile=false
		fi
	done

	if [[ ${isVaildFile} == false ]]; then
		MessageBuilder printErrorMessage ${file}-does-not-exist.-please-check-your-spelling-or-try-another-file
	elif [[ ${isValidFile} ]]; then
		cat ${filePath} | grep '[a-z]*(){'
	fi
}

listSources(){
	sources=($(DocsUtil getSources))

	echo "The following files are available as sources:"

	for s in ${sources[@]}
		echo "	${s}"
	done
}

clear
case ${1} in
	-[dD]) listDependenciesFromSource ${2};;
	-[gG]) listAllMethodsFromSource;;
	-[hH]) HelpMessage docsHelpMessage;;
	-[mM]) listMethodsFromSource ${2};;
	-[sS]) listSources;;
	*) echo "Not a valid option; please try again."
esac