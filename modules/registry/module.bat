@echo off
setlocal enableextensions enabledelayedexpansion

:: name: registry
:: version: 1.0.0
:: author: Ferris Atassi
:: description: Collects registry information of users and the system.
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: users, registry hives, profiles

:: TODO: update module-name
set _mod_name= registry

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

  ::"" TODO: update tool(s) and remove this check if module is cross-architecture
   ::check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set RCP=%_mod_tools%\RawCopy64.exe
 ) else (
  set RCP=%_mod_tools%\RawCopy.exe
  )

  call:module
  goto:eof

:module
:: TODO: list TODO items

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  ::TODO: build command(s) based on the details of the module and its tool(s), see example below:
  call "%_mod_util%\log" "[%_mod_name%] collecting registry hives" "%_LOG%"

  call "%_mod_util%\log" "system registry hives"
	call "%_mod_util%\exec" "%RCP% /FileNamePath:%SystemRoot%\System32\config\SAM /OutputPath:%_mod_output%" "%_mod_output%\registry_hives.log" "%_mod_name%"
	call "%_mod_util%\exec" "%RCP% /FileNamePath:%SystemRoot%\System32\config\SECURITY /OutputPath:%_mod_output%" "%_mod_output%\registry_hives.log" "%_mod_name%"
	call "%_mod_util%\exec" "%RCP% /FileNamePath:%SystemRoot%\System32\config\SOFTWARE /OutputPath:%_mod_output%" "%_mod_output%\registry_hives.log" "%_mod_name%"
	call "%_mod_util%\exec" "%RCP% /FileNamePath:%SystemRoot%\System32\config\SYSTEM /OutputPath:%_mod_output%" "%_mod_output%\registry_hives.log" "%_mod_name%"
	ren %_mod_output%\registry_hives.log\SAM SAM-live
	ren %_mod_output%\registry_hives.log\SECURITY SECURITY-live
	ren %_mod_output%\registry_hives.log\SOFTWARE SOFTWARE-live
	ren %_mod_output%\registry_hives.log\SYSTEM SYSTEM-live

  ::call "%_mod_util%\log" "user registry hives"
  
  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
