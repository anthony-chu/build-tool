include os/validator/OSValidator.sh
include string/util/StringUtil.sh

FileNameUtil(){
	getPath(){
		local path=${1}

		if [[ $(OSValidator isWindows) ]]; then
			_drive=${path:1:1}
			drive=${_drive^}
			headlessPath=${path/\/[a-z]/}

			echo ${drive}:${headlessPath}
		else
			echo ${path}
		fi
	}

	$@
}