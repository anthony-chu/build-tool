source String/StringValidator.sh

StringUtil(){
	replace(){
		local str=$1
		local orig=$2
		local new=$3

		if [[ $new == space ]]; then
			new=" "
		fi

		echo ${str//$orig/$new}
	}

	returnOption(){
		local opt=$1
		local isValidOpt=$(StringValidator isAlphaNum ${opt//-/})

		if [[ $isValidOpt == true ]]; then
			echo ${opt/-/ }
		fi
	}

	$@
}