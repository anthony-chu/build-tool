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

  buildDir=d:/$privacy/$branch-portal; bundleDir=d:/$privacy/$branch-bundles; database=lportal${branch//[-.]/""};;

  export args="${args}" branch="${branch}" buildDir="${buildDir}" bundleDir="${bundleDir}" database="${database}" tomcatDir="$bundleDir/tomcat-7.0.62"
}