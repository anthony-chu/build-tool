getBaseDir(){
    export baseDir=$(PWD)
}

getDirs(){
    if [[ $@ == *ee* ]]; then
        privacy=private
    else
        privacy=public
    fi

    if [[ $@ == *master* ]]; then
        branch=master
    elif [[ $@ == *ee-6.2.x* ]]; then
        branch=ee-6.2.x
    elif [[ $@ == *ee-7.0.x* ]]; then
        branch=ee-7.0.x
    else
        branch=master
    fi

    buildDir=d:/${privacy}/${branch}-portal
    bundleDir=d:/${privacy}/${branch}-bundles
    database=lportal${branch//[-.]/""}

    export branch="${branch}" buildDir="${buildDir}" bundleDir="${bundleDir}" database="${database}"
}