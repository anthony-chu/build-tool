source bash-toolbox/init.sh

include array.util.ArrayUtil
include array.validator.ArrayValidator

include command.validator.CommandValidator

include file.name.util.FileNameUtil
include file.util.FileUtil

include git.util.GitUtil

include help.message.HelpMessage

include logger.Logger

include props.writer.PropsWriter

include source.util.SourceUtil

include string.util.StringUtil

include repo.Repo

@private
_executeTest(){
	local test=${1}
	shift
	${_log} info "running_test_${test}_against_${branch}..."
	echo
	cd ${buildDir}
	ant -f build-test.xml run-selenium-test -Dtest.class="${test}" $@

	${_log} info "cleaning_up_temporary_test_files..."

	rm -rf ${bundleDir}/poshi/*

	${_log} info "completed"

	local testname=LocalFile.$(StringUtil replace test \# _)

	local resultDir=${buildDir}/portal-web/test-results/${testname}

	if [[ -d ${resultDir} ]]; then

		${_log} info "moving_test_results..."

		cp -r ${resultDir} ${testDir}

		cd ${testDir}/${testname}

		mv index.html ${test}_index.html

		local rawFile="${testDir}/${testname}/${test}_index.html"

		if [[ $(grep "Cause:" ${rawFile}) ]]; then
			FileUtil open "$(FileNameUtil getPath ${rawFile})"

			${_log} info "completed"
		else
			${_log} info "${test}_PASSED"
		fi
	fi
}

@description sets_necessary_test_properties
setup(){
	mkdir -p ${testDir}

	${_log} info "preparing_test_properties..."

	PropsWriter setTestProps ${branch} test.skip.tear.down true
	PropsWriter setTestProps ${branch} timeout.explicit.wait 30
	PropsWriter setTestProps ${branch} database.mysql.password
	PropsWriter setTestProps ${branch} database.mysql.schema lportal${branch}
	PropsWriter setTestProps ${branch} database.mysql.username

	local binFile=C:/chromium/chrome.exe

	PropsWriter setTestProps ${branch} browser.type chrome
	PropsWriter setTestProps ${branch} browser.chrome.bin.file ${binFile}

	${_log} info "completed"
}

@description formats_source_files
sf(){
	cd ${buildDir}/portal-impl

	local flag=$(StringUtil returnOption ${1})

	if [[ ${flag,,} == c ]]; then

		local option="-current-branch"
	elif [[ ${flag,,} == l ]]; then

		local option="-local-changes"
	else
		local option="_all_changes"
	fi

	local _msg=(
		running_source-formatter_on
		$(StringUtil replace option - _)
		_$(GitUtil getCurBranch)
	)

	${_log} info "$(StringUtil join _msg)"

	if [[ ${option} != _all_changes ]]; then
		ant format-source${option}
	else
		ant format-source
	fi

	${_log} info "completed"
}

@description executes_a_frontend_test
test(){
	if [[ ! ${1} ]]; then
		${_log} error "missing_test_name"

		return
	fi

	local tests=${1}

	shift

	setup

	for _test in $(StringUtil split tests ,); do
		_executeTest ${_test} ${@}
	done
}

@description runs_poshi_validation
validate(){
	cd ${buildDir}

	local message=(
		running_
		$(StringUtil capitalize poshi)_
		validation_against_
		$(GitUtil getCurBranch)
	)

	${_log} info "$(StringUtil join message)..."

	ant -f build-test.xml run-poshi-validation $@

	${_log} info "completed"
}

main(){
	local args=($@)

	if [[ ! ${args[@]} ]]; then
		HelpMessage printHelpMessage

		return
	fi

	@param the_branch_name_\(optional\)
	local branch=$(Repo getBranch $@)

	if [[ $@ =~ ${branch} ]]; then
		local args=($(ArrayUtil strip args ${branch}))
	fi

	local _log="Logger log"

	local buildDir=$(Repo getBuildDir ${branch})
	local bundleDir=$(Repo getBundleDir ${branch})

	local testDir=/d/test-results/${branch}

	if [[ ${args[@]} == *\#* ]]; then
		test ${args[@]}
	else
		CommandValidator validateCommand ${0} ${1}

		if [[ $(ArrayValidator hasEntry args local.release) ]]; then
			local _file=${buildDir}/modules/test/poshi-runner/settings.gradle

			rm -rf ${_file}
		fi

		SourceUtil setupSDK

		${args[@]}
	fi
}

main $@