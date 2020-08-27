@echo off
setlocal enableextensions enabledelayedexpansion

:: name: events
:: version: 1.0.0
:: author: Ferris Atassi
:: description: Collects Windows event logs.
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: event logs

:: TODO: update module-name
set _mod_name=events

:setup
  :: TODO: remove when implemented
 

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
    set PLL=%_mod_tools%\psloglist64.exe
  ) else (
    set PLL=%_mod_tools%\psloglist.exe
  )

  call:module
  goto:eof

:module
  :: TODO: list TODO items

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"
  mkdir %_mod_output%\evtx

  ::TODO: build command(s) based on the details of the module and its tool(s), see example below:
  ::call "%_mod_util%\exec" "command" "output-file" "tag (usually %_mod_name%)" "%_mod_name%"
  call "%_mod_util%\log" "Collecting event logs in *.evtx format." "%_LOG%"
  
  FOR %%i in (C:\Windows\System32\winevt\Logs\*.evtx) do (
      call "%_mod_util%\exec" "%PLL% -accepteula -s %%~ni" "%_mod_output%\evtx\%%~ni.evtx.csv" "%_mod_name%"
  ) 

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  goto:eof
