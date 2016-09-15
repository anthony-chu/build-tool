source ${projectDir}lib/self.sh

include(){
	source ${projectDir}${1}
}

self call include