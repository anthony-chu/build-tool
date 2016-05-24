Formatter(){
	formatTabs(){
		sed -i "s/	/\t/g" $1
	}

	formatSpaceAfterTab(){
		sed -i "s/\t /\t/g" $1
	}

	formatTrailingSpaces(){
		sed -i "s/} \+$/}/g" $1
	}

	$@
}

curFile=${0/.\//}
allFiles=($(find * -type f))
includedFiles=(${allFiles[@]/*$curFile/})

for (( i=0; i<${#includedFiles[@]}; i++ )); do
	Formatter formatTabs ${includedFiles[i]}
	Formatter formatSpaceAfterTab ${includedFiles[i]}
	Formatter formatTrailingSpaces ${includedFiles[i]}
done