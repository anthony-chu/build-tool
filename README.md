# How to Use This Tool

### build.sh

Enter script name followed by successive arguments
- Example:
    ```
    $ ./build.sh pull push build
    ```
Each argument is a separate command


### branch.sh

Enter script file name followed by an argument
- Example:
    ```
    $ ./build.sh build
    ```
This argument is the command

Follow the command with necessary arguments
- Example:
    ```
    $ ./build.sh build tomcat
    ```

For a brief explanation of each command, call the script without passing  
in any arguments. This will bring up the help message for each available  
command in the active script.

- Example:
    ```
    $ ./build.sh
    ```
This will bring up the help message for the build.sh script.