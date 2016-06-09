# build-tool

### Jump to section

- [About](#about)
- [Using the tool](#using-the-tool)
	- [build.sh](#buildsh)
	- [branch.sh](#branchsh)
	- [test.sh](#testsh)
- [Help!](#help)


## About
This tool includes three different scripts: build.sh, branch.sh, and test.sh. To view how each script works, use the shortcut links above to quickly jump to the section on the specific script.

## Using the tool
Each script may function in one of two ways.

- The argument provided to the script is the command executed.  
Example:  
	```
	$ ./branch.sh list
	```
In this case, _list_ is the command executed.

- The argument provided to the command provides more information for the command to execute.  
Example:  
	```
	$ ./build.sh build tomcat
	```
In this case, the command executed is _build_, and the option (the app server, in this case) is _tomcat_.


## Help!  
#### A list of available commands for each script can be obtained by calling the script without providing any commands to be executed:  
Example:  

		$ ./build.sh  
This will bring up the list of commands available for use in the _build.sh_ script.