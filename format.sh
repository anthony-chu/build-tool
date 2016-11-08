source ${projectDir}.init.sh

include array.validator.ArrayValidator
include file.util.FileUtil
include file.io.util.FileIOUtil
include finder.Finder
include logger.Logger
include string.validator.StringValidator

Format(){
	applyUnixLineEndings(){
		file=${1}

		FileIOUtil replace ${file} "\r\n" "\n"
	}

	convertSpacesToTabs(){
		file=${1}

		sed -i "s/[ ][ ]/\t/g" ${file}
		sed -i "s/[ ][ ][ ][ ]/\t/g" ${file}
	}

	enforceLoggerMessageQuotes(){
		file=${1}

		lineNumber=1

		while read line; do
			if [[ ${line} =~ Logger && ${line} == *log*Msg* && ${line} != *Completed* ]]; then
				if [[ ${line} != *\"* ]]; then
					Logger logErrorMsg "unquoted_logging_message:_${file}:${lineNumber}"
				fi
			fi

			lineNumber=$((${lineNumber}+1))
		done < ${file}
	}

	verifyNoIncludesInBase(){
		file=${1}

		if [[ $(StringValidator isSubstring ${file} Base) && ! $(StringValidator
			isSubstring ${file} Test) ]]; then

			if [[ $(FileUtil getContent ${file}) =~ include ]]; then
				Logger logErrorMsg "illegal_include:_${file}"
			fi
		fi
	}

	verifyNoPackagesInBase(){
		file=${1}

		if [[ $(StringValidator isSubstring ${file} Base) && ! $(StringValidator
			isSubstring ${file} Test) ]]; then

			if [[ $(FileUtil getContent ${file}) =~ package ]]; then
				Logger logErrorMsg "illegal_package:_${file}"
			fi
		fi
	}

	$@
}

Logger logProgressMsg "validating_formatting_rules"

files=($(Finder findBySubstring sh))

tasks=(
	applyUnixLineEndings
	convertSpacesToTabs
	enforceLoggerMessageQuotes
	verifyNoIncludesInBase
	verifyNoPackagesInBase
)

for file in ${files[@]}; do
	for task in ${tasks[@]}; do
		Format ${task} ${file}
	done
done

Logger logCompletedMsg