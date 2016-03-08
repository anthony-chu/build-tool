source String/StringValidator.sh

AppServerValidator(){
    isJboss(){
        local appServer=$1

        if [[ $appServer == jboss ]]; then
            echo true
        else
            echo false
        fi
    }

    isJonas(){
        local appServer=$1

        if [[ $appServer == jonas ]]; then
            echo true
        else
            echo false
        fi
    }

    isTomcat(){
        local appServer=$1

        if [[ $appServer == tomcat ]]; then
            echo true
        else
            echo false
        fi
    }

    isWeblogic(){
        local appServer=$1

        if [[ $appServer == weblogic ]]; then
            echo true
        else
            echo false
        fi
    }

    isWebsphere(){
        local appServer=$1

        if [[ $appServer == websphere ]]; then
            echo true
        else
            echo false
        fi
    }

    isWildfly(){
        local appServer=$1

        if [[ $appServer == wildfly ]]; then
            echo true
        else
            echo false
        fi
    }

    returnAppServer(){
        local appServer=$1

    	if [[ $(StringValidator isNull $appServer) == true ]]; then
    		echo "tomcat"
    	else
    		if [[ $(validateAppServer $appServer) == true ]]; then
    			echo $appServer
    		else
    			echo
                exit
    		fi
    	fi
    }

    validateAppServer(){
        validAppServer=(jboss jonas tomcat weblogic websphere wildfly)

    	for (( i=0; i<${#validAppServer[@]}; i++ )); do
    		local isValidAppServer=$(StringValidator isEqual ${validAppServer[i]} $1)

    		if [[ $isValidAppServer == true ]]; then
    			break
    		fi
    	done

    	echo $isValidAppServer
    }

    $@
}