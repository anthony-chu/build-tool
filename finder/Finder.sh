include finder/util/FinderUtil.sh

Finder(){
	findAllFiles(){
		FinderUtil _find
	}

	findBySubstring(){
		FinderUtil _find | grep ${1}
	}

	$@
}