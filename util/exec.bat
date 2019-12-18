@echo off
setlocal enableextensions

:: exec.bat <command> <output-file> <tag>
:: executes <command>, redirects console (stdout and stderr) to <output-file>
:: logs execution details labeled with <tag>

set _cmd=%~1
set _out=%~2
set _tag=%~3

call "%~dp0log" "[%_tag%] executing command: %_cmd%" "%_LOG%"
call "%~dp0log" "[%_tag%] sending console output to %_out%" "%_LOG%"

:: replace "" with " because some programs don't know how to handle double-double quotes
:: see https://stackoverflow.com/questions/4094699/how-does-the-windows-command-interpreter-cmd-exe-parse-scripts/4094897#4094897
:: @echo on
(%_cmd:""="%) >> "%_out%" 2>&1
:: @echo off
