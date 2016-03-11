# build-tool

### Jump to section

- [About](#About)
- [Using the tool](#Using the tool)
    - [build.sh](#build.sh)
    - [branch.sh](#branch.sh)
    - [test.sh](#test.sh)
- [Help!](#Help!)


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

### build.sh

This script will perform the following actions:
- Pull updates to your local branch
- Push changes to your remote branch
- Build a bundle on the indicated app server
- Run a bundle on the indicated app server
- Deploy module(s) to your bundle

### branch.sh

This script will perform the following actions:
- Retrieve a list of available branches on the indicated branch
- Display the current branch
- Display the log for a given branch
- Create a new branch on the selected source folder
- Delete a branch on the selected source folder
- Restore the source to a designated commit in history
- Perform an interactive rebase
- Pull source code from the indicated remote branch
- Display a formatted message for use with JIRA
- Provide direct shell access to the indicated source folder

### test.sh

This script will perform the following actions:
- Execute a test against the currently running portal instance and display its results
- Format the source code using portal's formatter
- Run validation against Poshi code
- Submit a pull request to the indicated user

## Help!  
#### A list of available commands for each script can be obtained by calling the script without providing any commands to be executed:  
Example:  

        $ ./build.sh  
This will bring up the list of commands available for use in the _build.sh_ script.