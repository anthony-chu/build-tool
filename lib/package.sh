source ${projectDir}lib/self.sh

package(){
	local dir=${1}

	local files=($(find * -type f -iname '*.sh' | grep ${dir}/))

	for file in ${files[@]}; do
		source ${file}
	done
}

self call package