source Message/MessageBuilder.sh

Formatter(){
	convertSpacesToTab(){
		sed -i "s/    /\t/g" $1
	}

	formatVars(){
		sed -i "s/\$\([a-zA-Z0-9_-]\+\)/\${\1\}/g" $1
	}

	removeSpacesAfterTab(){
		sed -i "s/\t /\t/g" $1
	}

	trimTrailingSpaces(){
		sed -i "s/}[ 	]\+$/}/g" $1
	}

	$@
}

allFiles=($(find * -type f))
availableMethods=(convertSpacesToTab formatVars removeSpacesAfterTab trimTrailingSpaces)
curFile=${0/.\//}
excludedFiles=(${curFile} md)
includedFiles=()

for (( i=0; i<${#allFiles[@]}; i++ )); do
	for (( j=0; j<${#excludedFiles[@]}; j++ )); do
		if [[ ${allFiles[i]} == *${excludedFiles[j]}* ]]; then
			continue
		else
			includedFiles+=(${allFiles[i]})
		fi
	done
done

MB(){
	MessageBuilder $@
}

MB printInfoMessage "Formatting bash files.."

for (( i=0; i<${#includedFiles[@]}; i++ )); do
	for (( j=0; j<${#availableMethods[@]}; j++ )); do
		Formatter ${availableMethods[j]} ${includedFiles[i]}
	done
done

MB printDone