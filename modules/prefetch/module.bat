@echo off
setlocal enableextensions enabledelayedexpansion

:: name: prefetch
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects parsed prefetch data
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, processed, activity, malware

set _mod_name=prefetch

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
    set _winprefetchview=%_mod_tools%\WinPrefetchView64.exe
  ) else (
    set _winprefetchview=%_mod_tools%\WinPrefetchView.exe
  )

  call:module
  goto:eof

:module
  :: TODO: support vss like ir-rescue

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: gather list of all prefetch files, with basic metadata
  call "%_mod_util%\exec" "%_winprefetchview% /scomma ""%_mod_output%\winprefetchview.csv""" "%_mod_output%\winprefetchview.log" "%_mod_name%"

  :: parse details of each prefetch file (MUST double-quote paths that might contain spaces)
  mkdir "%_mod_output%\parsed"
  for /F "usebackq delims=" %%i in (`dir /B /S "%SystemRoot%\Prefetch\*.pf" 2^>NUL`) do (
    set _pf=%%i
    set _pf_root=%%~ni
    call "%_mod_util%\exec" "%_winprefetchview% /prefetchfile ""!_pf!"" /sort ~7 /scomma ""%_mod_output%\parsed\!_pf_root!.csv""" "%_mod_output%\winprefetchview.log" "%_mod_name%"
  )

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
