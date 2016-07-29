# build-tool

### Table of Contents
1. [About](#about)
2. [The Main Toolkit](#the-main-toolkit)
	- [build.sh](#buildsh)
	- [branch.sh](#branchsh)
	- [test.sh](#testsh)
3. [Additional Tools](#additional-tools)
	- [doc.sh](#docsh)
	- [format.sh](#formatsh)
3. [Help!](#help)

## About

The build-tool project began as a simple automation exercise but has evolved to become a tool that is used daily for the purpose of expediting repetitive tasks such as building portal or running a functional test against a portal bundle. There are three main scripts - [build.sh](#buildsh), [branch.sh](#branchsh), and [test.sh](#testsh) - that do much of the work of automating tasks related to building and/or testing portal. Additionally, there are two other scripts - [doc.sh](#docsh) and [format.sh](#formatsh) - that aid in improving the existing main scripts.

## The Main Toolkit

As mentioned previously, the build tool consists of three main tools - [build.sh](#buildsh), [branch.sh](#branchsh), and [test.sh](#testsh). The functionality of these three scripts will be covered below. Also available for use are two additional scripts - [doc.sh](#docsh) and [format.sh](#formatsh) - which serve as helps to add features to or improve the existing scripts. Take a look below as the function and purpose of each script is explored:

### build.sh

The goal of this script is to update and build portal based on two key parameters passed into the CLI at runtime when calling the script - the branch and the application server. Based on these two parameters, `build.sh` will update portal source code and compile a bundle on the desired branch using the desired app server. After successfully building portal, you may also use build.sh to run an instance of portal on the desired app server.

- **Examples of use:**
	- `$ build.sh pull master` - This will update the current master branch to HEAD; replacing `pull` with `push` will update your remote origin branch to your local HEAD.
	- `$ build.sh build tomcat master` - This will build a Tomcat bundle using the master branch; replacing `tomcat` with another valid app server will build a bundle using that app server.
	- `$ build.sh run tomcat master` - This will start up an instance of portal on the master branch using the Tomcat application server; as previously mentioned, replacing `tomcat` with any a subset of valid application servers will start up portal on that application server as well.

	<sup>\* Replacing <code>master</code> with another branch will execute the same function on the specified branch.</sup>

### branch.sh

The goal of this script is to allow a user to view information on a specified local branch of portal based on a parameter passed in at runtime into the CLI - the branch name. Using this parameter, `branch.sh` can retrieve information about the specific branch of portal. Alternatively, this script can be used to navigate between branches as well as generate debugging information; optionally, this can take an additional `${appServer}` parameter at runtime when calling the specific function.

- **Examples of use:**
	- `$ branch.sh switch ${branch}` - This will switch from the current master branch to the default master branch; alternatively, replace `${branch}` with any other branch to switch to that specific branch.
	- `$ branch.sh reset ${branch}` - This will remove any local changes made to the master branch; alternatively, replacing `master` with another branch will remove all local changes made to that branch. Passing in a SHA (long or short) before the branch will reset portal to that specific commit.
	- `$ branch.sh rebase -${option} ${branch}` - This will trigger a rebase based on the option provided on the master branch; replacing `${branch}` with another branch name will trigger a rebased on that branch.
	- `$ branch.sh log ${int} ${branch}` - This will return the short SHA of the last `${int}` commits along with their commit messages. Replacing `${branch}` with another branch name will return a list of commits on that branch.
	- `$ branch.sh jira ${option} ${appServer} ${branch}`- This will return debugging information used for creating JIRA tickets. The `${option}` will determine which debugging message is printed; the `${appServer}` and `${branch}` parameters are optional and extend `jira` to print app-server- and branch-specific debugging information.

### test.sh

The goal of this script is to automate automation testing and test-writing tools. Some of the tools automated include Poshi functional test automation, Poshi functional test file validation, Portal source formatting, and pull request automation. To find out more, execute the following in your command line interface (CLI):
- `$ test.sh` - This will print the `test.sh` help message with the available standalone functions.

## Additional Tools

When the original three scripts were written, they were written in a monolithic, non-modular convention. However, the need to reuse elements across different scripts led to the modularization of the monolithic scripts through the use of functions. To this end, two new scripts were added in order to aid in adding new functionality to the main scripts. To learn more about these two new scripts, continue reading below.

### doc.sh

The purpose of this script is to provide users with visibility into the different files available to source as well as the individual functions that can be used from each source file.

### format.sh

The purpose of this script is to format all bash scripts to match selected formatting standards (more are being added) before they are committed to this repository.

## Help!

Finally, if what you are looking for is beyond the scope of this README document, all you need to do is call the script without providing any parameters, and a help message pertaining to the script will display, listing all the functionality provided in that script.

- **Example:**
	- `$ build.sh` - This will bring up the help message for the `build.sh` script, listing out all of the available standalone functions.