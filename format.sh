source ${projectDir}.init.sh

include array.validator.ArrayValidator
include file.util.FileUtil
include finder.Finder
include logger.Logger
include string.validator.StringValidator

Format(){
	convertSpacesToTabs(){
		file=${1}

		sed -i "s/[ ][ ]/\t/g" ${file}
		sed -i "s/[ ][ ][ ][ ]/\t/g" ${file}
	}

	verifyNoIncludesInBase(){
		file=${1}

		if [[ $(StringValidator isSubstring ${file} Base) && ! $(StringValidator
			isSubstring ${file} Test) ]]; then

			if [[ $(FileUtil getContent ${file}) =~ include ]]; then
				Logger logErrorMsg illegal_include:_base_scripts_cannot_include_other_scripts:_${file}
			fi
		fi
	}

	verifyNoPackagesInBase(){
		file=${1}

		if [[ $(StringValidator isSubstring ${file} Base) && ! $(StringValidator
			isSubstring ${file} Test) ]]; then

			if [[ $(FileUtil getContent ${file}) =~ package ]]; then
				Logger logErrorMsg illegal_include:_base_scripts_cannot_use_other_script_packages:_${file}
			fi
		fi
	}

	$@
}

Logger logProgressMsg validating_formatting_rules

files=($(Finder findBySubstring sh))
tasks=(convertSpacesToTabs verifyNoIncludesInBase verifyNoPackagesInBase)

for file in ${files[@]}; do
	for task in ${tasks[@]}; do
		Format ${task} ${file}
	done
done

Logger logCompletedMsg