package(){
	dir=${1}

	files=($(find * -type f -iname '*.sh' | grep ${dir}))

	for file in ${files[@]}; do
		source ${file}
	done
}

if [[ $1 == package ]]; then
	$@
fi