@echo off
setlocal enableextensions

:: name: process
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects volatile, processed process data from various built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: volatile, processed

set _mod_name=process

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
    set _driverview=%_mod_tools%\driverview-x64\DriverView.exe
    set _pslist=%_mod_tools%\sysinternals\pslist64.exe
    set _psservice=%_mod_tools%\sysinternals\PsService64.exe
    set _listdlls=%_mod_tools%\sysinternals\Listdlls64.exe
    set _handle=%_mod_tools%\sysinternals\handle64.exe
  ) else (
    set _driverview=%_mod_tools%\driverview\DriverView.exe
    set _pslist=%_mod_tools%\sysinternals\pslist.exe
    set _psservice=%_mod_tools%\sysinternals\PsService.exe
    set _listdlls=%_mod_tools%\sysinternals\Listdlls.exe
    set _handle=%_mod_tools%\sysinternals\handle.exe
  )

  if not exist "%_pslist%" (
    call "%_mod_util%\log" "[%_mod_name%] required tools not available; run %~dp0make.bat to get them" "%_LOG%"
    popd & exit /B 1
  )

  call:module
  goto:eof

:module
  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  call "%_mod_util%\exec" "tasklist /V" "%_mod_output%\tasklist-v.txt" "%_mod_name%"
  call "%_mod_util%\exec" "tasklist /M" "%_mod_output%\tasklist-m.txt" "%_mod_name%"
  call "%_mod_util%\exec" "driverquery /FO csv /V" "%_mod_output%\driverquery.csv" "%_mod_name%"
  call "%_mod_util%\exec" "%_driverview% /sort ~12 /scomma ""%_mod_output%\driverview.csv""" "%_mod_output%\driverview.log" "%_mod_name%"

  :: TODO: consider whether to include the following from ir-rescue:
  :: reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs" /S >> %MAL%\dlls-known.txt 2>&1
  :: (reg query HKLM\SYSTEM\CurrentControlSet\Services\ /S | %GREP% -E "HKEY_LOCAL_MACHINE\\\\SYSTEM\\\\CurrentControlSet\\\\Services\\\\|DisplayName|ImagePath|ServiceDll" | %GREP% -F -v "ServiceDllUnloadOnStop") >> %MAL%\svcs.txt 2>&1

  call "%_mod_util%\exec" "%_pslist% -accepteula" "%_mod_output%\pslist.txt" "%_mod_name%"
  call "%_mod_util%\exec" "%_pslist% -t -accepteula" "%_mod_output%\pslist-t.txt" "%_mod_name%"

  call "%_mod_util%\exec" "%_handle% -accepteula -s" "%_mod_output%\handle-s.txt" "%_mod_name%"
  call "%_mod_util%\exec" "%_handle% -accepteula -u" "%_mod_output%\handle-u.txt" "%_mod_name%"
  call "%_mod_util%\exec" "%_handle% -accepteula -a" "%_mod_output%\handle-a.txt" "%_mod_name%"

  call "%_mod_util%\exec" "%_listdlls% -accepteula -r -v" "%_mod_output%\listdlls.txt" "%_mod_name%"

  :: TODO: consider whether to include the following from ir-rescue:
  :: call:cmd %MAL%\arg "%GREP% -F 'Command line: ' %MAL%\dlls-unsign.txt

  call "%_mod_util%\exec" "tasklist /svc" "%_mod_output%\tasklist-svc.txt" "%_mod_name%"
  call "%_mod_util%\exec" "sc queryex" "%_mod_output%\sc-queryex.txt" "%_mod_name%"
  call "%_mod_util%\exec" "%_psservice% -accepteula" "%_mod_output%\psservice.txt" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
