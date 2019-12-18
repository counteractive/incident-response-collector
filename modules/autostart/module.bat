@echo off
setlocal enableextensions enabledelayedexpansion

:: name: autostart
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects persistent, processed autostart data from various built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, processed, malware

set _mod_name=autostart

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

  :: check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set _autoruns=%_mod_tools%\sysinternals\autorunsc64.exe
  ) else (
    set _autoruns=%_mod_tools%\sysinternals\autorunsc.exe
  )

  if not exist "%_autoruns%" (
    call "%_mod_util%\log" "[%_mod_name%] required tools not available; run %~dp0make.bat to get them" "%_LOG%"
    popd & exit /B 0
  )

  call:module
  goto:eof

:module
  :: TODO: convert autoruns output to utf-8

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: built-in windows network commands
  call "%_mod_util%\exec" "schtasks /query /FO csv /V" "%_mod_output%\schtasks.csv" "%_mod_name%"

  :: 3rd-party tools
  :: autoruns with all types, csv output, file hashes, verified signatures, and normalized (UTC) timestamps
  call "%_mod_util%\exec" "%_autoruns% -accepteula -a * -c -h -s -t" "%_mod_output%\autoruns.csv" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
