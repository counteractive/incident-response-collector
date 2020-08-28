@echo off
setlocal enableextensions enabledelayedexpansion

:: name: app dumps
:: version: 1.0.0
:: author: Sarah Garelick
:: description: collects memory-artifacts data from app dumps
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: custom

:: TODO: update module-name
set _mod_name=yara_scans

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
    set _yara=%_mod_tools%\yara64.exe
    rem yara(32|64) is the YARA main executable
    rem yarac (32|64) is the YARA rules compiler
  ) else (
    set _yara=%_mod_tools%\yara32.exe
  )

  call:module
  goto:eof

:module
  :: TODO: list TODO items

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  ::build command(s) based on the details of the module and its tool(s)
::  for /F "tokens=*" %%i in ('dir /B /S %_mod_util%\rules\*.yar') do (
::      call "%_mod_util%\exec" "%_yara% -m %%i C:\Windows\%_system%" "%_mod_name%"
::      call "%_mod_util%\exec" "%_yara% -m %%i C:\Windows\%_system%\drivers" "%_mod_name%"
::)
  for /F "tokens=*" %%i in ('dir /B /S rules\*.yar') do (
        for /F %%j in (%_mod_tools%\nonrecursive.txt) do (
          call "%_mod_util%\exec" "%_yara% -m %%i %%j" "%_mod_output%\yara.log" "%_mod_name%"       
           )
        for /F %%j in (%_mod_tools%\recursive.txt) do (
          call "%_mod_util%\exec" "%_yara% -m -r %%i %%j" "%_mod_output%\yara.log" "%_mod_name%"
        )
      )



  ::call "%_mod_util%\exec" "%_yara% -m /yara_scans" "%_mod_output%\yara.log" "%_mod_name%"
  ::call "%_mod_util\exec" "%_yarac%" "%_mod_output%\yarac.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof