@echo off

:: name: files
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects selected raw files using built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project.
::        3rd-party tools are used and/or shared per the terms of their respective licences.
::        See the NOTICE file at the root of this project for details.
:: tags: raw, persistent

set _mod_name=files

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

  call:module
  goto:eof

:module
  :: TODO: support vss like ir-rescue

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: copy prefetch files
  :: note: forecopy creates prefetch sub-folder automatically
  call "%_mod_util%\log" "[%_mod_name%] copying prefetch files" "%_LOG%"
  call "%_mod_util%\exec" "%_forecopy% --prefetch ""%_mod_output%""" "%_mod_output%\forecopy-prefetch.log" "%_mod_name%"

  :: copy evtx files
  :: note: forecopy creates eventlogs subfolder automatically
  call "%_mod_util%\log" "[%_mod_name%] copying event log files" "%_LOG%"
  call "%_mod_util%\exec" "%_forecopy% --evtlog ""%_mod_output%""" "%_mod_output%\forecopy-evtlog.log" "%_mod_name%"

  :: copy registry hives
  :: note: forecopy creates registry subfolder automatically
  call "%_mod_util%\log" "[%_mod_name%] copying registry hive files" "%_LOG%"
  call "%_mod_util%\exec" "%_forecopy% --registry ""%_mod_output%""" "%_mod_output%\forecopy-registry.log" "%_mod_name%"

  :: copy system32/drivers/etc files
  :: note: forecopy creates etc subfolder automatically
  call "%_mod_util%\log" "[%_mod_name%] copying system32/drivers/etc files" "%_LOG%"
  call "%_mod_util%\exec" "%_forecopy% --etc ""%_mod_output%""" "%_mod_output%\forecopy-registry.log" "%_mod_name%"

  :: copy amcache hive
  call "%_mod_util%\log" "[%_mod_name%] copying amcache hive file" "%_LOG%"
  call "%_mod_util%\exec" "%_forecopy% -f %WINDIR%\AppCompat\Programs\Amcache.hve ""%_mod_output%""" "%_mod_output%\forecopy-amcache.log" "%_mod_name%"

  :: copy task files
  call "%_mod_util%\log" "[%_mod_name%] copying task files" "%_LOG%"
  mkdir "%_mod_output%\tasks"
  mkdir "%_mod_output%\tasks\system32"
  mkdir "%_mod_output%\tasks\syswow64"
  call "%_mod_util%\exec" "%_forecopy% --recursive ""%SystemRoot%\Tasks"" ""%_mod_output%\tasks""" "%_mod_output%\forecopy-tasks.log" "%_mod_name%"
  call "%_mod_util%\exec" "%_forecopy% --recursive ""%SystemRoot%\System32\Tasks"" ""%_mod_output%\tasks\system32""" "%_mod_output%\forecopy-tasks.log" "%_mod_name%"
  if exist "%PROGRAMFILES(X86)%" (
    call "%_mod_util%\exec" "%_forecopy% --recursive ""%SystemRoot%\SysWOW64\Tasks"" ""%_mod_output%\tasks\syswow64""" "%_mod_output%\forecopy-tasks.log" "%_mod_name%"
  )

  :: copy common log files
  call "%_mod_util%\log" "[%_mod_name%] copying IIS log files" "%_LOG%"
  set _iislogs=%SystemDrive%\inetpub\logs\LogFiles
  if exist "%_iislogs%" (
    mkdir "%_mod_output%\iis-logs"
    call "%_mod_util%\exec" "%_forecopy% --recursive ""%_iislogs%"" ""%_mod_output%\iis-logs""" "%_mod_output%\forecopy-iis.log" "%_mod_name%"
  ) else (
    call "%_mod_util%\log" "[%_mod_name%] iis logs directory does not exist at %_iislogs%" "%_LOG%"
  )

  :: move forecopy_handy.log from working directory to output directory
  call "%_mod_util%\log" "[%_mod_name%] moving forecopy log file" "%_LOG%"
  call "%_mod_util%\exec" "move forecopy_handy.log ""%_mod_output%\forecopy.log""" "%_mod_output%\cleanup.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
