Finder(){
	findByExt(){
		ext=${1}

		find * -type f -iname *.${ext}
	}

	$@
}