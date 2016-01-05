getBaseDir(){
  export baseDir=$(PWD)
}

getDirs(){
  args=$@

  if [[ $args == *ee* ]]; then
      privacy=private
  else
      privacy=public
  fi

  if [[ $args == *master* ]]; then
    branch=master
  elif [[ $args == *ee-6.2.x* ]]; then
    branch=ee-6.2.x
  else
    branch=master
  fi

  if [[ $args == *pr* ]]; then
    args=${args}
  else
    args=${args/$branch/""}
  fi

  case $branch in
    "ee-6.2.x") buildDir=d:/private/ee-6.2.x-portal; bundleDir=d:/private/ee-6.2.x-bundles; database=lportal;;
    "master") buildDir=d:/public/master-portal; bundleDir=d:/public/master-bundles; database=lportalmaster;;
  esac

  export args="${args}" branch="${branch}" buildDir="${buildDir}" bundleDir="${bundleDir}" database="${database}" tomcatDir="$bundleDir/tomcat-7.0.62"
}