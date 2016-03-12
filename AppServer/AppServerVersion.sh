AppServerVersion(){
    _glassfishVersion(){
        echo "3.1.2.2"
    }

    _jettyVersion(){
        echo "8.1.10"
    }

    _jbossVersion(){
        echo "eap-6.4.0"
    }

    _jonasVersion(){
        echo "5.2.3"
    }

    _resinVersion(){
        echo "4.0.44"
    }

    _tcatVersion(){
        echo "7.0.2"
    }

    _tcserverVersion(){
        echo "2.9.11"
    }

    _tomcatVersion(){
        echo "8.0.32"
    }

    _weblogicVersion(){
        echo "12.1.3"
    }

    _websphereVersion(){
        echo "8.5.5.0"
    }

    _wildflyVersion(){
        echo "10.0.0"
    }

    returnAppServerVersion(){
        local appServer=$1

        echo $(_${appServer}Version)
    }

    $@
}