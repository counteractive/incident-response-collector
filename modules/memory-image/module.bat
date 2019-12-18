@echo off
setlocal enableextensions

:: name: memory-image
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects a memory image
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details. If run as a stand-alone script, output will be created in module directory subfolder, but still needs to be run from within package, as it requires the util directory.
:: tags: volatile, raw

set _mod_name=memory-image

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
    set _ramcapture=%_mod_tools%\RamCapture64.exe
  ) else (
    set _ramcapture=%_mod_tools%\RamCapture.exe
  )

  call:module
  goto:eof

:module
  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  call "%_mod_util%\timestamp"
  call "%_mod_util%\exec" "%_ramcapture% ""%_mod_output%\%COMPUTERNAME%-%_ISO8601%.memory.dmp""" "%_mod_output%\%_mod_name%.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
