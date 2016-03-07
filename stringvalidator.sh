StringValidator(){
    isAlpha(){
        local str=$1

        if [[ $str =~ [a-zA-Z\ ] ]]; then
            echo true
        else
            echo false
        fi
    }

    isAlphaNum(){
        local str=$1

        if [[ $str =~ [a-zA-Z0-9\ ] ]]; then
            echo true
        else
            echo false
        fi
    }

    isEqual(){
        local str1=$1
        local str2=$2

        if [[ $str1 == $str2 ]]; then
            echo true
        else
            echo false
        fi
    }

    isNull(){
        local string=$1

        if [[ $string ]]; then
            echo false
        else
            echo true
        fi
    }

    isNum(){
        local str=$1

        if [[ $str =~ [0-9] ]]; then
            echo true
        else
            echo false
        fi
    }

    $1
}