source Base/File/Util/BaseFileUtil.sh
source Message/Builder/MessageBuilder.sh

PropsReader(){
	readConfFile(){
		file=${1}

		if [[ $(BaseFileUtil getFileExtension ${file}) != conf ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-conf-file.
			exit
		fi

		MessageBuilder printInfoMessage reading-configuration-from-${file}.

		properties=($(cat ${file}))

		for (( i=0; i<${#properties[@]}; i++ )); do
			eval ${properties[i]]}
		done
	}

	readPropsFile(){
		file=${1}

		if [[ $(BaseFileUtil getFileExtension ${file}) != properties ]]; then
			MessageBuilder printErrorMessage -${file}-is-not-a-properties-file.
			exit
		fi

		MessageBuilder printInfoMessage reading-properties-from-${file}.

		properties=($(cat ${file}))

		for (( i=0; i<${#properties[@]}; i++ )); do
			eval ${properties[i]]}
		done
	}

	$@
}