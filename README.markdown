# build-tool

### Table of Contents
1. [Announcements](#announcements)
2. [About](#about)
2. [The Main Toolkit](#the-main-toolkit)
	- [build.sh](#buildsh)
	- [branch.sh](#branchsh)
	- [test.sh](#testsh)
4. [Additional Tools](#additional-tools)
	- [build-test.sh](#build-testsh)
5. [Help!](#help)

## Announcements

I am pleased to announce that the `src` directory is no more and has since been
replaced by the `bash-toolbox` project, which you can learn more about [here](
	https://github.com/anthony-chu/bash-toolbox). It is currently being
maintained by the git-submodule package, which you can learn more about [here](
	https://git-scm.com/book/en/v2/Git-Tools-Submodules).

## About

The build-tool project began as a simple automation exercise but has evolved to
become a tool that is used daily for the purpose of expediting repetitive tasks
such as building portal or running a functional test against a portal bundle.
There are three main scripts - [build.sh](#buildsh), [branch.sh](#branchsh), and
[test.sh](#testsh) - that do much of the work of automating tasks related to
building and/or testing portal.

## The Main Toolkit

### build.sh

The goal of this script is to update and build portal based on two key
parameters passed into the CLI at runtime when calling the script - the branch
and the application server. Based on these two parameters, `build.sh` will
update portal source code and compile a bundle on the desired branch using the
desired app server. After successfully building portal, you may also use
build.sh to run an instance of portal on the desired app server.

- **Examples of use:**
	- `$ build.sh pull master` - This will update the current master branch to
	HEAD; replacing `pull` with `push` will update your remote origin branch to
	your local HEAD.
	- `$ build.sh build tomcat master` - This will build a Tomcat bundle using
	the master branch; replacing `tomcat` with another valid app server will
	build a bundle using that app server.
	- `$ build.sh run tomcat master` - This will start up an instance of portal
	on the master branch using the Tomcat application server; as previously
	mentioned, replacing `tomcat` with a subset of valid application servers
	will start up portal on that application server as well.

	<sup>\* Replacing <code>master</code> with another branch will execute the
	same function on the specified branch.</sup>
	</br>
	<sup>\*\* The parameters <code>master</code> and <code>tomcat</code> are
	implicit for <code>build.sh</code> and <code>branch.sh</code>. For <code>
	test.sh</code>, the parameter <code>master</code> is implicit. This means
	not passing in a branch and/or app server parameter will cause the script to
	assume the master branch and tomcat app server.</sup>

### branch.sh

The goal of this script is to allow a user to view information on a specified
local branch of portal based on a parameter passed in at runtime into the CLI -
the branch name. Using this parameter, `branch.sh` can retrieve information
about the specific branch of portal. Alternatively, this script can be used to
navigate between branches as well as generate debugging information; optionally,
this can take an additional `${appServer}` parameter at runtime when calling the
specific function.

- **Examples of use:**
	- `$ branch.sh switch ${branch}` - This will switch from the current master
	branch to the default master branch; alternatively, replace `${branch}`
	with any other branch to switch to that specific branch.
	- `$ branch.sh reset ${branch}` - This will remove any local changes made to
	the master branch; alternatively, replacing `master` with another branch
	will remove all local changes made to that branch. Passing in a SHA
	(long or short) before the branch will reset portal to that specific commit.
	- `$ branch.sh rebase -${option} ${branch}` - This will trigger a rebase
	based on the option provided on the master branch; replacing `${branch}`
	with another branch name will trigger a rebased on that branch.
	- `$ branch.sh log ${int} ${branch}` - This will return the short SHA of the
	last `${int}` commits along with their commit messages. Replacing
	`${branch}` with another branch name will return a list of commits on that
	branch.
	- `$ branch.sh jira ${option} ${appServer} ${branch}`- This will return
	debugging information used for creating JIRA tickets. The `${option}` will
	determine which debugging message is printed; the `${appServer}` and
	`${branch}` parameters are optional and extend `jira` to print app-server-
	and branch-specific debugging information.

### test.sh

The goal of this script is to automate automation testing and test-writing
tools. Some of the tools automated include Poshi functional test automation,
Poshi functional test file validation, Portal source formatting, and pull
request automation. To find out more, execute the following in your command line
interface (CLI):
- `$ test.sh` - This will print the `test.sh` help message with the available
standalone functions.

## Additional Tools

When the original three scripts were written, they were written in a monolithic,
non-modular convention. However, the need to reuse elements across different
scripts led to the modularization of the monolithic scripts through the use of
functions. To this end, a new script was added in order to aid in adding new
functionality to the main scripts. To learn more about these the new script,
continue reading below.

### build-test.sh

As the number of functions grew, there arose a need to maintain some level of
testing across the source scripts. `build-test.sh` (along with the `test`
directory) were created in order to do just that. You will find in the `test/`
directory `TestExecutor.sh` along with an assortment of unit tests for many of
the functions.

## Help!

Finally, if what you are looking for is beyond the scope of this README
document, all you need to do is call the script without providing any
parameters, and a help message pertaining to the script will display, listing
all the functionality provided in that script.

- **Example:**
	- `$ build.sh` - This will bring up the help message for the `build.sh`
	script, listing out all of the available standalone functions.