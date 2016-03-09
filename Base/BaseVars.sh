BaseVars(){
    _returnPrivacy(){
        if [[ $@ == *ee* ]]; then
            echo private
        else
            echo public
        fi
    }

    returnBaseDir(){
        pwd
    }

    returnBranch(){
        if [[ $@ == *master* ]]; then
            branch=master
        elif [[ $@ == *ee-6.2.x* ]]; then
            branch=ee-6.2.x
        elif [[ $@ == *ee-7.0.x* ]]; then
            branch=ee-7.0.x
        else
            branch=master
        fi

        echo $branch
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