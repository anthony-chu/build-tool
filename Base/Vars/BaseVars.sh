BaseVars(){
	_returnPrivacy(){
		if [[ $@ == *ee-* ]]; then
			echo private
		else
			echo public
		fi
	}

	returnBaseDir(){
		pwd
	}

	returnBranch(){
		case $@ in
			*ee-6.1.x*) echo ee-6.1.x;;
			*ee-6.2.x*) echo ee-6.2.x;;
			*ee-7.0.x*) echo ee-7.0.x;;
			*6.1.x*) echo 6.1.x;;
			*6.2.x*) echo 6.2.x;;
			*master*) echo master;;
			*7.0.x*) echo 7.0.x;;
			*) echo master;;
		esac
	}

	returnBuildDir(){
		local branch=$(returnBranch $@)
		local privacy=$(_returnPrivacy $@)

		echo "d:/${privacy}/${branch}-portal"
	}

	returnBundleDir(){
		local branch=$(returnBranch $@)
		local privacy=$(_returnPrivacy $@)

		echo "d:/${privacy}/${branch}-bundles"
	}

	$@
}