@echo off
setlocal enableextensions enabledelayedexpansion

:: log.bat <message> <logfile>
:: writes <message> with timestamp, to console and <logfile>

call "%~dp0timestamp"
set _msg=%_ISO8601% - %~1
echo %_msg%

:: only log to existing file.
:: enables modules called alone to use log with _LOG unset or stale.
if exist "%~2" (
  set _log=%~2
) else (
  set _log=nul
)
echo %_msg% >> "!_log!"
