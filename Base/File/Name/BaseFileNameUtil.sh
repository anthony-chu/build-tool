source Base/BaseUtil.sh
source String/StringUtil.sh

BaseFileNameUtil(){
	getPath(){
		path=${1}

		if [[ $(BaseUtil getOS) =~ Windows ]]; then
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