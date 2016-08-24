include File/Util/FileUtil.sh
include Message/Builder/MessageBuilder.sh
include String/Validator/StringValidator.sh

PropsReader(){
	readConfFile(){
		file=${1}

		if [[ $(FileUtil getExtension ${file}) != conf ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-conf-file.
			exit
		fi

		MessageBuilder printProgressMessage reading-configuration-from-${file}

		properties=($(FileUtil getContent ${file}))

		if [[ $(StringValidator isNull ${properties[@]}) ]]; then
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

		if [[ $(FileUtil getExtension ${file}) != properties ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-properties-file.
			exit
		fi

		MessageBuilder printProgressMessage reading-properties-from-${file}

		properties=($(FileUtil getContent ${file}))

		if [[ $(StringValidator isNull ${properties[@]}) ]]; then
			MessageBuilder printErrorMessage there-are-no-properties-in-${file}
			exit
		fi

		for p in ${properties[@]}; do
			eval ${p}
		done

		MessageBuilder printDone
	}

	$@
}