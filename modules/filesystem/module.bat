@echo off
setlocal enableextensions

:: name: filesystem
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects persistent, raw filesystem metadata data
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, raw, filesystem, files

set _mod_name=filesystem

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
    set _rawcopy=%_mod_tools%\RawCopy\RawCopy64.exe
    set _extractusnjrnl=%_mod_tools%\ExtractUsnJrnl\ExtractUsnJrnl64.exe
  ) else (
    set _rawcopy=%_mod_tools%\RawCopy\RawCopy.exe
    set _extractusnjrnl=%_mod_tools%\ExtractUsnJrnl\ExtractUsnJrnl.exe
  )

  call:module
  goto:eof

:module
  :: DONE: consider using forecopy to reduce complexity - don't do it, buggy
  :: TODO: support multiple drives, like ir-rescue (which can fix the substring workaround below)
  :: TODO: support VSS, like ir-rescue

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: copy $MFT file from %systemdrive% (like BrimorLabs Live Response)
  call "%_mod_util%\log" "[%_mod_name%] copying $MFT" "%_LOG%"
  call "%_mod_util%\exec" "%_rawcopy% /FileNamePath:%SYSTEMDRIVE:~0,1%:0 /OutputPath:""%_mod_output%""" "%_mod_output%\$mft.log" "%_mod_name%"
  call "%_mod_util%\exec" "ren ""%_mod_output%\$MFT"" $MFT-systemdrive.bin" "%_mod_output%\$mft.log" "%_mod_name%"

  :: copy $LogFile file from %systemdrive% (like BrimorLabs Live Response)
  :: rename extracted file to reflect the drive it came from (like ir-rescue)
  call "%_mod_util%\log" "[%_mod_name%] copying $LogFile" "%_LOG%"
  call "%_mod_util%\exec" "%_rawcopy% /FileNamePath:%SYSTEMDRIVE:~0,1%:2 /OutputPath:""%_mod_output%""" "%_mod_output%\$logfile.log" "%_mod_name%"
  call "%_mod_util%\exec" "ren ""%_mod_output%\$LogFile"" $LogFile-systemdrive.bin" "%_mod_output%\$logfile.log" "%_mod_name%"

  :: extract usnjrnl file from %systemdrive% (like BrimorLabs Live Response)
  :: note: /OutputPath does not support relative paths, must pass quoted absolute path (_mod_output should be)
  ::       see https://github.com/jschicht/ExtractUsnJrnl/blob/master/ExtractUsnJrnl.au3#L121
  :: rename extracted file to reflect the drive it came from (like ir-rescue)
  call "%_mod_util%\log" "[%_mod_name%] copying $UsnJrnl:$J" "%_LOG%"
  call "%_mod_util%\exec" "%_extractusnjrnl% /DevicePath:%SYSTEMDRIVE% /OutputPath:""%_mod_output%""" "%_mod_output%\$usnjrnl.log" "%_mod_name%"
  call "%_mod_util%\exec" "ren ""%_mod_output%\$UsnJrnl_$J.bin"" $UsnJrnl_$J-systemdrive.bin" "%_mod_output%\$usnjrnl.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
