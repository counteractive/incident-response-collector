@echo off
setlocal enableextensions enabledelayedexpansion

:: name: memory-files
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects persistent, raw memory data from the filesystem
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, raw, memory

set _mod_name=memory-files

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

  :: cross-platform
  set _forecopy=%_mod_tools%\forecopy_handy.exe

  :: check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set _rawcopy=%_mod_tools%\RawCopy\RawCopy64.exe
  ) else (
    set _rawcopy=%_mod_tools%\RawCopy\RawCopy.exe
  )

  call:module
  goto:eof

:module
  :: TODO: support vss like ir-rescue
  :: TODO: pull app dump files

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: copy hiberfil.sys file
  call "%_mod_util%\log" "[%_mod_name%] copying hiberfil.sys file" "%_LOG%"
  if exist "%SystemDrive%\hiberfil.sys" (
    call "%_mod_util%\exec" "%_forecopy% --file %SystemDrive%\hiberfil.sys ""%_mod_output%""" "%_mod_output%\forecopy-hiberfil.log" "%_mod_name%"
  ) else (
    call "%_mod_util%\log" "[%_mod_name%] hiberfil.sys does not exist at %SystemDrive%\hiberfil.sys" "%_LOG%"
  )

  :: copy pagefile.sys file(s)
  :: pulls location from registry, skips two lines, then cuts "/??/" from path (3rd token, or "%%k")
  call "%_mod_util%\log" "[%_mod_name%] copying pagefile.sys file from location in HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\ExistingPageFiles" "%_LOG%"
  for /F "skip=2 tokens=1-3" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /V ExistingPageFiles') do (
    set _pagefile=%%k
    set _pagefile=!_pagefile:~4!
  )
  if exist "%_pagefile%" (
    :: forecopy fails on pagefile, for reasons unknown.  using rawcopy works.
    :: call "%_mod_util%\exec" "%_forecopy% --file ""%_pagefile%"" ""%_mod_output%""" "%_mod_output%\forecopy-pagefile.log" "%_mod_name%"
    call "%_mod_util%\exec" "%_rawcopy% /FileNamePath:""%_pagefile%"" /OutputPath:""%_mod_output%""" "%_mod_output%\rawcopy-pagefile.log" "%_mod_name%"
  ) else (
    call "%_mod_util%\log" "[%_mod_name%] pagefile does not exist at %_pagefile%" "%_LOG%"
  )

  :: copy minidump
  :: pulls location from registry, skips two lines, then uses path (3rd token, or "%%k")
  call "%_mod_util%\log" "[%_mod_name%] copying minidump files from location in HKLM\System\CurrentControlSet\Control\CrashControl\MinidumpDir" "%_LOG%"
  for /F "skip=2 tokens=1-3" %%i in ('reg query "HKLM\System\CurrentControlSet\Control\CrashControl" /V MinidumpDir') do (
    set _minidumpdir=%%k
  )
  if exist "%_minidumpdir%" (
    mkdir "%_mod_output%\minidumps"
    call "%_mod_util%\exec" "%_forecopy% --recursive ""!_minidumpdir!"" ""%_mod_output%\minidumps""" "%_mod_output%\forecopy-minidump.log" "%_mod_name%"
  ) else (
    call "%_mod_util%\log" "[%_mod_name%] minidump directory does not exist at !_minidumpdir!" "%_LOG%"
  )

  :: copy app dump files
  :: call "%_mod_util%\log" "[%_mod_name%] copying app dump files" "%_LOG%"
  :: TODO: loop through user profiles and copy "!uprofiles[%%i]!\AppData\Local\CrashDumps"

  call "%_mod_util%\log" "[%_mod_name%] moving forecopy log file" "%_LOG%"
  call "%_mod_util%\exec" "move forecopy_handy.log ""%_mod_output%\forecopy.log""" "%_mod_output%\cleanup.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
