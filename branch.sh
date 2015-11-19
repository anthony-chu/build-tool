source setdir.sh

current(){
  cd $buildDir

  name="$(git rev-parse --abbrev-ref HEAD)"

  echo "Current branch: $name"

  cd $baseDir
}

list(){
  cd $buildDir

  git branch

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

getBaseDir
getDirs $@

if [[ $# > 1 ]]; then
  $1 ${@:2}
else
  if [[ $args == *#* ]]; then
    args="test $args"
    $args
  else
    $1
  fi
fi
