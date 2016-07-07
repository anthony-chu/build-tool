Finder(){
	findAllFiles(){
		find * -type f
	}

	findByExt(){
		ext=${1}

		find * -type f -iname '*.${ext}'
	}

	$@
}