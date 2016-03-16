source AppServer/AppServerValidator.sh
source AppServer/AppServerVersion.sh
source Base/BaseUtil.sh
source Base/BaseVars.sh
source Help/HelpMessage.sh
source Message/MessageFactory.sh
source String/StringValidator.sh

MF=MessageFactory

_hardReset(){
    cd $buildDir

    git pull upstream

    git reset --hard

    git clean -fdqx -e "*.anthonychu.properties"

    cd $baseDir
}

_longLog(){
    cd $buildDir

     git --git-dir=${buildDir}/.git rev-parse origin/$branch

    cd $baseDir
}

changes(){
    cd $buildDir

    git status

    cd $baseDir
}

current(){
  cd $buildDir

  name=$(git rev-parse --abbrev-ref HEAD)

  $MF printInfoMessage "Current ${branch} branch: $name"

  cd $baseDir
}

delete(){
    cd $buildDir

    if [[ $1 == $(git rev-parse --abbrev-ref HEAD) ]]; then
        $MF printErrorMessage "Cannot delete the current branch"
    else
        git branch -q -D $1
        $MF printInfoMessage "Deleted local branch: $1"
    fi

    cd $baseDir
}

dev(){
    cd $buildDir

    local dev=$1
    local branch=$2

    git pull git@github.com:$dev/liferay-portal.git $branch

    cd $baseDir

    log
}

jira(){
    local _gitid=$(_longLog)

    if [[ $branch == master ]]; then
        branch=${branch^}
    else
        branch=$branch
    fi

    local gitinfo="Portal $branch GIT ID: ${_gitid}"

    fixed(){
        echo Fixed on:
    }

    nlr(){
        echo No Longer Reproducible on:
    }

    repro(){
        echo Reproduced on:
    }

    _env(){
        local appServer=$(AppServerValidator returnAppServer $1)
        local appServerVersion=$(AppServerVersion
            returnAppServerVersion $appServer)

        echo ${appServer^} ${appServerVersion} + MySQL 5.7
    }

    case $1 in
        fixed|nlr|repro) $1;;
        *) echo "" ;;
    esac

    echo $(_env $2)
    echo ${gitinfo}
}

list(){
  cd $buildDir

  git branch

  cd $baseDir
}

log(){
    cd $buildDir

    if [[ $# == 0 ]]; then
        git log -1 --oneline
    else
        git log -$1 --oneline
    fi

    cd $baseDir
}

new(){
  cd $buildDir

  git checkout -q -b $1

  current

  cd $baseDir
}

rebase(){
    abort(){
        $MF printInfoMessage "Terminating previous rebase process.."

        cd $buildDir

        git rebase --abort

        cd $baseDir

        $MF printDone
    }

    amend(){
        $MF printInfoMessage "Amending the previous commit.."

        cd $buildDir

        git commit --amend

        cd $baseDir

        $MF printDone
    }

    cont(){
        $MF printInfoMessage "Continuing the current rebase process.."

        cd $buildDir

        git rebase --continue

        cd $baseDir

        $MF printDone
    }

    default(){
        $MF printInfoMessage "Rebasing current branch to HEAD.."

        cd $buildDir

        git pull --rebase upstream ${branch}

        cd $baseDir

        $MF printDone
    }

    start(){
        local value=$(StringUtil returnOption $1)

        if [[ $value > 1 ]]; then
            isPlural=s
        else
            isPlural=""
        fi

        $MF printInfoMessage "Rebasing the last $value commit${isPlural}.."

        cd $buildDir

        git rebase -i head~$value

        cd $baseDir

        $MF printDone
    }

    if [[ $(StringValidator isNull $1) == true ]]; then
        $MF printErrorMessage "Please provide a valid rebase option"
        exit
    fi

    case $(StringUtil returnOption $1) in
        [0-9]*) start $1;;
        q) abort;;
        c) cont;;
        a) amend;;
        d) default;;
    esac
}

rename(){
    cd $buildDir

    local originalBranch=$(git rev-parse --abbrev-ref HEAD)

    git branch -q -m $1

    $MF printInfoMessage "Renamed branch from $originalBranch to $1"

    cd $baseDir
}

reset(){
  cd $buildDir

  git reset --hard $1

  cd $baseDir
}

switch(){
  cd $buildDir

  if [[ $# == 0 ]]; then
      b=master
  else
      b=$1
  fi

  git checkout -q $b

  current

  cd $baseDir
}

tunnel(){
    cd $buildDir

    local tunnelCommand=""
    while [[ true ]]; do
        echo -n "Enter git command to run (begin with git): "
        read tunnelCommand

        $tunnelCommand
        echo
        echo
    done

    cd $baseDir
}

clear
baseDir=$(BaseVars returnBaseDir)
branch=$(BaseVars returnBranch $@)
buildDir=$(BaseVars returnBuildDir $@)
bundleDir=$(BaseVars returnBundleDir $@)

if [[ $# == 0 ]]; then
  HelpMessage branchHelpMessage
else
    if [[ $1 == ${branch} ]]; then
        shift
    fi

    $@
fi