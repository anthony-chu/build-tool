# HOW TO USE

### build

Enter script name followed by successive arguments
- Example:
    ```
    $ build.sh pull push build
    ```

Each argument is a separate command


### test

Enter script file name followed by an argument
- Example:
    ```
    $ test.sh rebase
    ```
This argument is the command

Follow the command with necessary arguments
- Example:
    ```
    $ test.sh master $TESTCASE#COMMAND
    ```