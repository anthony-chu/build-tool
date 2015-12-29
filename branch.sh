source setdir.sh

_hardReset(){
    cd $buildDir

    git pull upstream

    git reset --hard

    git clean -fdqx -e "*.anthonychu.properties"

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

hardReset(){
    cd $buildDir

    git pull upstream

    git reset --hard

    git clean -fdqx -e "*.anthonychu.properties"

    cd $baseDir
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

  echo "Checked out a new branch: $1"

  cd $baseDir
}

switch(){
  cd $buildDir

  git checkout -q $1

  echo "Switched to an existing branch: $1"

  cd $baseDir
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

getBaseDir
getDirs $@

if [[ $# > 1 ]]; then
  $1 ${@:2}
else
  if [[ $args == *#* ]]; then
    args="test $args"
    "$args"
  else
    $1
  fi
fi