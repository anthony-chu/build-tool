include Finder/Util/FinderUtil.sh

Finder(){
	findAllFiles(){
		FinderUtil _find
	}

	findBySubstring(){
		FinderUtil find -iname *.${1}
	}

	findByName(){
		FinderUtil find -iname ${1}
	}

	$@
}