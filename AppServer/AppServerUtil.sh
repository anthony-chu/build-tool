source AppServer/AppServerValidator.sh
source AppServer/AppServerVersion.sh
source Base/BaseVars.sh

AppServerUtil(){

    ASValidator=AppServerValidator

    copyDatabaseJar(){
        local appServer=$($ASValidator returnAppServer $@)
        local branch=$(BaseVars returnBranch $@)
        shift
        shift

        if [[ $branch == ee-7.0.x ]] && [[ $appServer == tomcat ]]; then
            appServerVersion=8.0.30
        elif [[ $branch == ee-6.2.x ]] && [[ $appServer == tomcat ]]; then
            appServerVersion=7.0.62
        else
            appServerVersion=$(AppServerVersion
				returnAppServerVersion $appServer)
        fi

        local bundleDir=$(BaseVars returnBundleDir $@)
        local appServerDir=${bundleDir}/${appServer}-${appServerVersion}

        local jarDir="C:/users/liferay/Desktop"
        local jarFile="mysql.jar"

        if [[ $($ASValidator isTomcat $appServer) == true ]]; then
            destDir=$appServerDir/lib/ext
        elif [[ $($ASValidator isWildfly $appServer) == true ]]; then
            destDir=$appServerDir/modules/com/liferay/portal/main
        fi

        rm -f $destDir/$jarFile
        cp -f $jarDir/$jarFile $destDir
    }

    $@
}