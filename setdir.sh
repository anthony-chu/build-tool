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
        tomcatVersion=8.0.32
    elif [[ $@ == *ee-6.2.x* ]]; then
        branch=ee-6.2.x
        tomcatVersion=7.0.62
    elif [[ $@ == *ee-7.0.x* ]]; then
        branch=ee-7.0.x
        tomcatVersion=8.0.32
    else
        branch=master
        tomcatVersion=8.0.32
    fi

    buildDir=d:/${privacy}/${branch}-portal
    bundleDir=d:/${privacy}/${branch}-bundles
    database=lportal${branch//[-.]/""}

    export branch="${branch}" buildDir="${buildDir}" bundleDir="${bundleDir}" database="${database}" tomcatDir="$bundleDir/tomcat-$tomcatVersion"
}