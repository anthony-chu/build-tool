source Base/File/Util/BaseFileUtil.sh
source String/Validator/StringValidator.sh
source Message/Builder/MessageBuilder.sh

PropsReader(){
	readConfFile(){
		file=${1}

		if [[ $(BaseFileUtil getFileExtension ${file}) != conf ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-conf-file.
			exit
		fi

		MessageBuilder printProgressMessage reading-configuration-from-${file}

		properties=($(cat ${file}))

		if [[ $(StringValidator isNull ${properties[@]}) == true ]]; then
			MessageBuilder printErrorMessage there-are-no-properties-in-${file}
			exit
		fi

		for (( i=0; i<${#properties[@]}; i++ )); do
			eval ${properties[i]]}
		done

		MessageBuilder printDone
	}

	readPropsFile(){
		file=${1}

		if [[ $(BaseFileUtil getFileExtension ${file}) != properties ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-properties-file.
			exit
		fi

		MessageBuilder printProgressMessage reading-properties-from-${file}

		properties=($(cat ${file}))

		if [[ $(StringValidator isNull ${properties[@]}) == true ]]; then
			MessageBuilder printErrorMessage there-are-no-properties-in-${file}
			exit
		fi

		for (( i=0; i<${#properties[@]}; i++ )); do
			eval ${properties[i]]}
		done

		MessageBuilder printDone
	}

	$@
}