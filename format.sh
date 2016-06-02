source Array/ArrayUtil.sh
source String/StringValidator.sh
source Formatter/FormatterUtil.sh

Formatter(){
	convertSpacesToTab(){
		sed -i "s/[ ][ ][ ][ ]/\t/g" ${1}
	}

	formatVars(){
		sed -i "s/\$\([a-zA-Z0-9_-]\+\)/\${\1\}/g" ${1}
	}

	removeSpacesAfterTab(){
		sed -i "s/\t /\t/g" ${1}
	}

	trimTrailingSpaces(){
		sed -i "s/}[ 	]\+$/}/g" ${1}
	}

	$@
}

allFiles=($(find * -type f))
availableMethods=(convertSpacesToTab formatVars removeSpacesAfterTab trimTrailingSpaces)
curFile=${0/\.\//}
excludedFiles=(${curFile} Formatter md)
includedFiles=()

echo "[INFO] Determining files to format..."

for (( i=0; i<${#allFiles[@]}; i++ )); do
	for (( j=0; j<${#excludedFiles[@]}; j++ )); do
		isEmptyArray=$(StringValidator isNull "${includedFiles[@]}")
		isUniqueFile=$(ArrayUtil hasUniqueEntry ${includedFiles[@]} ${allFiles[i]})

		if [[ ${isEmptyArray} == true ]]; then
			excludedStatus=$(FormatterUtil getExcludeStatus ${allFiles[i]} ${excludedFiles[j]})
		else
			if [[ ${isUniqueFile} == true ]]; then
				excludedStatus=$(FormatterUtil getExcludeStatus ${allFiles[i]} ${excludedFiles[j]})
			else
				continue
			fi
		fi

		if [[ ${excludedStatus} == true ]]; then
			break
		fi
	done

	if [[ ${excludedStatus} == false ]]; then
		includedFiles+=(${allFiles[i]})
	fi
done

echo "[INFO] Done."
echo

echo "[INFO] Applying formatting rules..."
for (( i=0; i<${#includedFiles[@]}; i++ )); do
	for (( j=0; j<${#availableMethods[@]}; j++ )); do
		Formatter ${availableMethods[j]} ${includedFiles[i]}
	done
done
echo "[INFO] Done."