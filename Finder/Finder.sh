include Finder/Util/FinderUtil.sh

Finder(){
	findAllFiles(){
		FinderUtil find
	}

	findByExt(){
		FinderUtil find -iname *.${1}
	}

	findByName(){
		FinderUtil find -iname ${1}
	}

	$@
}