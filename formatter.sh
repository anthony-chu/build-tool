Formatter(){
	convertSpacesToTab(){
		sed -i "s/	/\t/g" $1
	}

	formatVars(){
		sed -i "s/\$\([a-zA-Z]\+\)/\${\1\}/g" $1
	}

	removeSpacesAfterTab(){
		sed -i "s/\t /\t/g" $1
	}

	trimTrailingSpaces(){
		sed -i "s/} \+$/}/g" $1
	}

	$@
}

curFile=${0/.\//}
allFiles=($(find * -type f))
includedFiles=(${allFiles[@]/*$curFile/})

for (( i=0; i<${#includedFiles[@]}; i++ )); do
	Formatter convertSpacesToTab ${includedFiles[i]}
	Formatter formatVars ${includedFiles[i]}
	Formatter removeSpacesAfterTab ${includedFiles[i]}
	Formatter trimTrailingSpaces ${includedFiles[i]}
done