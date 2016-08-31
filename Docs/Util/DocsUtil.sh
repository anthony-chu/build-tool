include Array/Validator/ArrayValidator.sh
include String/Validator/StringValidator.sh

DocsUtil(){
	getSources(){
		allFiles=($(find * -type f -iname "*.sh"))
		excludedFiles=($(find * -type f -name "[a-z]*.sh"))

		listableFiles=()

		for a in ${allFiles[@]}; do
			for e in ${excludedFiles[@]}; do
				isEmptyArray=$(StringValidator isNull "${listableFiles[@]}")
				isUniqueFile=$(ArrayValidator hasUniqueEntry ${listableFiles[@]} ${a})

				if [[ ${isEmptyArray} ]]; then
					excludedStatus=$(StringValidator isSubstring ${a} ${e})
				else
					if [[ ${isUniqueFile} ]]; then
						excludedStatus=$(StringValidator isSubstring ${a} ${e})
					else
						continue
					fi
				fi

				if [[ ${excludedStatus} ]]	; then
					break
				fi

			done

			if [[ ${excludedStatus} == false ]]; then
				listableFiles+=(${a})
			fi
		done

		echo "${listableFiles[@]}"
	}

	$@
}