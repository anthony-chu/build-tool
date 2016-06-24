source Array/Validator/ArrayValidator.sh
source String/Validator/StringValidator.sh

DocsUtil(){
	getSources(){
		allFiles=($(find * -type f -iname "*.sh"))
		excludedFiles=($(find * -type f -name "[a-z]*.sh"))

		listableFiles=()

		for (( i=0; i<${#allFiles[@]}; i++ )); do
			for (( j=0; j<${#excludedFiles[@]}; j++ )); do
				isEmptyArray=$(StringValidator isNull "${listableFiles[@]}")
				isUniqueFile=$(ArrayValidator hasUniqueEntry ${listableFiles[@]} ${allFiles[i]})

				if [[ ${isEmptyArray} == true ]]; then
					excludedStatus=$(StringValidator isSubstring ${allFiles[i]} ${excludedFiles[j]})
				else
					if [[ ${isUniqueFile} == true ]]; then
						excludedStatus=$(StringValidator isSubstring ${allFiles[i]} ${excludedFiles[j]})
					else
						continue
					fi
				fi

				if [[ ${excludedStatus} == true ]]	; then
					break
				fi

			done

			if [[ ${excludedStatus} == false ]]; then
				listableFiles+=(${allFiles[i]})
			fi
		done

		echo "${listableFiles[@]}"
	}
}