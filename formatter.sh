Formatter(){
	curFile=${0/.\//}
	allFiles=($(find * -type f))
	includedFiles=(${allFiles[@]/*$curFile/})

	formatTabs(){
		for (( i=0; i<${#includedFiles[@]}; i++ )); do
			sed -i "s/	/\t/g" ${includedFiles[i]}
		done
	}

	formatSpaceAfterTab(){
		for (( i=0; i<${#includedFiles[@]}; i++ )); do
			sed -i "s/\t /\t/g" ${includedFiles[i]}
		done
	}

	$@
}

Formatter formatTabs
Formatter formatSpaceAfterTab