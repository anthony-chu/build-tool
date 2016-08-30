include OS/Validator/OSValidator.sh
include String/Util/StringUtil.sh

FileNameUtil(){
	getPath(){
		path=${1}

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