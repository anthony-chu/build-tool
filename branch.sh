source setdir.sh
source util.sh
source help.sh

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

current(){
  cd $buildDir

  name="$(git rev-parse --abbrev-ref HEAD)"

  echo "Current branch: $name"

  cd $baseDir
}

delete(){
    cd $buildDir

    if [[ $1 == $(git rev-parse --abbrev-ref HEAD) ]]; then
        echo "Cannot delete the current branch"
    else
        git branch -q -D $1
        echo "Deleted local branch: $1"
    fi

    cd $baseDir
}

dev(){
    cd $buildDir

    dev=$1
    branch=$2

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
        echo "Fixed on:"
    }

    nlr(){
        echo "No Longer Reproducible on:"
    }

    repro(){
        echo "Reproduced on:"
    }

    _env(){
        echo "Tomcat 8.0.30 + MySQL 5.6"
    }

    case $1 in
        fixed|nlr|repro) $1;;
        *) echo "" ;;
    esac

    echo $(_env)
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
        echo "[INFO] Terminating previous rebase process..."

        cd $buildDir

        git rebase --abort

        cd $baseDir

        echo "[INFO] DONE."
    }

    amend(){
        echo "[INFO] Amending the previous commit..."

        cd $buildDir

        git commit --amend

        cd $baseDir

        echo "[INFO] DONE."
    }

    cont(){
        echo "[INFO] Continuing the current rebase process..."

        cd $buildDir

        git rebase --continue

        cd $baseDir

        echo "[INFO] DONE."
    }

    default(){
        echo "[INFO] Rebasing current branch to HEAD..."

        cd $buildDir

        git pull --rebase upstream master

        cd $baseDir

        echo "[INFO] DONE."
    }

    start(){
        if [[ $opt > 1 ]]; then
            isPlural="s"
        else
            isPlural=""
        fi

        echo "Rebasing the last $opt commit${isPlural}..."

        cd $buildDir

        git rebase -i head~$opt

        cd $baseDir

        echo "[INFO] DONE."
    }

    export opt=$1

    case $opt in
        [0-9]*) start;;
        abort|amend|cont) $opt;;
        *) default;;
    esac
}

rename(){
    cd $buildDir

    originalBranch="$(git rev-parse --abbrev-ref HEAD)"

    git branch -q -m $1

    echo "Renamed branch from $originalBranch to $1"

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

    tunnelCommand=""
    while [[ true ]]; do
        echo -n "Enter git command to run (begin with git): "
        read tunnelCommand

        if [[ $tunnelCommand == q ]]; then
            exit
        else
            $tunnelCommand
            echo
            echo
        fi
    done

    cd $baseDir
}

clear
getBaseDir
getDirs $@

if [[ $# == 0 ]]; then
  branch_help
else
    $@
fi