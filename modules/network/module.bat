@echo off
setlocal enableextensions enabledelayedexpansion

:: name: network
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects volatile, processed network data from various built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: volatile, processed

set _mod_name=network

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
    set _cports=%_mod_tools%\cports-x64\cports.exe
  ) else (
    set _cports=%_mod_tools%\cports\cports.exe
  )

  call:module
  goto:eof

:module
  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: built-in windows network commands
  call "%_mod_util%\exec" "ipconfig /all" "%_mod_output%\ipconfig-all.txt" "%_mod_name%"
  call "%_mod_util%\exec" "ipconfig /displaydns" "%_mod_output%\ipconfig-dns.txt" "%_mod_name%"
  call "%_mod_util%\exec" "netstat -abno" "%_mod_output%\netstat-abno.txt" "%_mod_name%"
  call "%_mod_util%\exec" "netstat -rn" "%_mod_output%\netstat-rn.txt" "%_mod_name%"
  call "%_mod_util%\exec" "nbtstat -c" "%_mod_output%\netbios-c.txt" "%_mod_name%"
  call "%_mod_util%\exec" "nbtstat -n" "%_mod_output%\netbios-n.txt" "%_mod_name%"
  call "%_mod_util%\exec" "nbtstat -S" "%_mod_output%\netbios-S.txt" "%_mod_name%"
  call "%_mod_util%\exec" "route print" "%_mod_output%\route-print.txt" "%_mod_name%"
  call "%_mod_util%\exec" "arp -a" "%_mod_output%\arp-a.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net use" "%_mod_output%\net-use.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net sessions" "%_mod_output%\net-sessions.txt" "%_mod_name%"
  :: slow :: call "%_mod_util%\exec" "net view" "%_mod_output%\net-view.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net statistics server" "%_mod_output%\net-statistics-server.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net statistics workstation" "%_mod_output%\net-statistics-workstation.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net share" "%_mod_output%\net-share.txt" "%_mod_name%"
  call "%_mod_util%\exec" "net file" "%_mod_output%\net-file.txt" "%_mod_name%"
  call "%_mod_util%\exec" "openfiles" "%_mod_output%\openfiles.txt" "%_mod_name%"

  :: 3rd-party tools
  call "%_mod_util%\exec" "%_cports% /scomma ""%_mod_output%\cports.csv""" "%_mod_output%\cports.log" "%_mod_name%"
  :: TODO: consider psfile (better version of net file, from sysinternals)
  :: TODO: consider tcpvcon/tcpview (from sysinternals)

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
