@echo off
setlocal enableextensions enabledelayedexpansion

:: name: hashes
:: version: 1.0.0
:: author: Sarah Garelick
:: description: TODO
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: files

:: TODO: update module-name
set _mod_name=hash_checks

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

  :: TODO: update tool(s) and remove this check if module is cross-architecture
  :: check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set _hash=%_mod_tools%\sha256deep64.exe
  ) else (
    set _hash=%_mod_tools%\sha256deep.exe
  )

  call:module
  goto:eof

:module
  :: TODO: list TODO items

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  ::TODO: build command(s) based on the details of the module and its tool(s), see example below:
  rem set _text=known.txt
  rem echo "%_text%"
  for /F %%j in (%_mod_tools%\nonrecursive.txt) do (
  rem -u -t -r -m known.txt*
  rem used for testing hashes
  rem call "%_mod_util%\exec" "%_hash% -u -t -r *" "known.txt" "%_mod_name%"
    call "%_mod_util%\exec" "%_hash% -m known.txt %%j*" "%_mod_output%\hash.log" "%_mod_name%"
  ) 
  for /F %%j in (%_mod_tools%\recursive.txt) do (
    call "%_mod_util%\exec" "%_hash% -r -m known.txt %%j*" "%_mod_output%\hash.log" "%_mod_name%"
  )

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
