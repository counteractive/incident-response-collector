@echo off
setlocal enableextensions enabledelayedexpansion

:: name: dirwalk
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects lists of persistent, processed file and directory data like filenames and hashes from various built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, processed

set _mod_name=dirwalk

:setup
  :: operate within this module's directory
  pushd "%~dp0"
  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] working in %cd%

  set _mod_util=..\..\util
  set _mod_tools=tools

  if not exist "%_mod_util%" (
    echo [%_mod_name%] required utilities not available.  exiting.
    popd & exit /B 1
  )

  if defined _OUT (
    :: running from main.bat
    set _mod_output=%_OUT%\%_mod_name%
  ) else (
    :: running stand-alone, output into subdirectory under module
    call "%_mod_util%\timestamp"
    set _mod_output=output-%_ISO8601%
  )

  :: confirm this module is enabled
  call "%_mod_util%\read-config" %_mod_name% _mod_enabled
  if not "%_mod_enabled%" == "true" (
    call "%_mod_util%\log" "[%_mod_name%] module not enabled" "%_LOG%"
    popd & exit /B 0
  )

  call "%_mod_util%\log" "[%_mod_name%] started module setup" "%_LOG%"
  mkdir "%_mod_output%"

  :: only uses built-in commands and tools

  call:module
  goto:eof

:module
  :: TODO: support other drives besides %systemdrive%

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: built-in windows commands
  :: sorted by written date (newest first), include owner, recursive, and ADSs
  call "%_mod_util%\exec" "dir /A /O:-D /Q /T:W /R /S %SYSTEMDRIVE%\" "%_mod_output%\dir-full.txt" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
