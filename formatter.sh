format_tabs(){
    thisFile=$0
    thisFile=${thisFile/.\//}
    bashFiles=($(ls *.sh))
    bashFiles=( ${bashFiles[@]/$thisFile/})

    echo ${bashFiles[@]}

    for (( i = 0; i < ${#bashFiles[@]}; i++ )); do
        sed -i "s/^[ ][ ][ ][ ]/    /g" $PWD/${bashFiles[i]}
        sed -i "s/[ ][ ][ ][ ]/    /g" $PWD/${bashFiles[i]}
    done
}

format_tabs