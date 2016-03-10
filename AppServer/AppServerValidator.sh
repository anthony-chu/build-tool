source String/StringValidator.sh

AppServerValidator(){
    local SV="StringValidator"

    isGlassfish(){
        local appServer=$1

        if [[ $($SV isEqual $appServer glassfish) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isJboss(){
        local appServer=$1

        if [[ $($SV isEqual $appServer jboss) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isJetty(){
        local appServer=$1

        if [[ $($SV isEqual $appServer jetty) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isJonas(){
        local appServer=$1

        if [[ $($SV isEqual $appServer jonas) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isResin(){
        local appServer=$1

        if [[ $($SV isEqual $appServer resin) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isTcat(){
        local appServer=$1

        if [[ $($SV isEqual $appServer resin) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isTCServer(){
        local appServer=$1

        if [[ $($SV isEqual $appServer tcserver) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isTomcat(){
        local appServer=$1

        if [[ $($SV isEqual $appServer tomcat) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isWeblogic(){
        local appServer=$1

        if [[ $($SV isEqual $appServer weblogic) == true ]]; then
            echo true
        else
            echo false
        fi
    }

    isWebsphere(){
        local appServer=$1

        if [[ $($SV isEqual $appServer websphere) == true ]]; then
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

    	if [[ $($SV isNull $appServer) == true ]]; then
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
        validAppServer=(
            glassfish
            jetty
            jboss
            jonas
            resin
            tcat
            tcserver
            tomcat
            weblogic
            websphere
            wildfly
        )

    	for (( i=0; i<${#validAppServer[@]}; i++ )); do
    		local isValidAppServer=$($SV isEqual ${validAppServer[i]} $1)

    		if [[ $isValidAppServer == true ]]; then
    			break
    		fi
    	done

    	echo $isValidAppServer
    }

    $@
}