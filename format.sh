source ${projectDir}lib/include.sh
source ${projectDir}lib/package.sh

include Finder/Finder.sh
include String/Validator/StringValidator.sh

package Array

Formatter(){
	convertSpacesToTab(){
		sed -i "s/[ ][ ][ ][ ]/\t/g" ${1}
	}

	formatVars(){
		sed -i "s/\$\([a-zA-Z0-9_-]\+\)/\${\1\}/g" ${1}
	}

	removeLineEndingSpace(){
		sed -i "s/[ ]\+$//g" ${1}
	}

	removeSpacesAfterTab(){
		sed -i "s/\t /\t/g" ${1}
	}

	trimTrailingSpaces(){
		sed -i "s/}[ 	]\+$/}/g" ${1}
	}

	$@
}

allFiles=($(Finder findBySubstring sh))

availableMethods=(
	convertSpacesToTab
	formatVars
	removeLineEndingSpace
	removeSpacesAfterTab
	trimTrailingSpaces
)

curFile=${0/\.\//}
excludedFiles=(${curFile} Formatter)
includedFiles=()

echo "[INFO] Determining files to format..."

for f in ${allFiles[@]}; do
	for e in ${excludedFiles[@]}; do
		isEmptyArray=$(StringValidator isNull "${includedFiles[@]}")
		isUniqueFile=$(ArrayValidator hasUniqueEntry ${includedFiles[@]} ${f})

		if [[ ${isEmptyArray} ]]; then
			excludedStatus=$(StringValidator isSubstring ${f} ${e})
		else
			if [[ ${isUniqueFile} ]]; then
				excludedStatus=$(StringValidator isSubstring ${f} ${e})
			else
				continue
			fi
		fi

		if [[ ${excludedStatus} ]]; then
			break
		fi
	done

	if [[ ${excludedStatus} == false ]]; then
		includedFiles+=(${f})
	fi
done

echo "[INFO] Done."
echo

echo "[INFO] Applying formatting rules..."

for f in ${includedFiles[@]}; do
	for m in ${availableMethods[@]}; do
		Formatter ${m} ${f}
	done
done
echo "[INFO] Done."