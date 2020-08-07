:: for sessions

@echo off
setlocal enableextensions enabledelayedexpansion

set _mod_name=sessions

:setup
  :: TODO: remove when implemented
  set _mod_util=..\..\util

  ::call "%_mod_util%\log" "[%_mod_name%] module not implented" "%_LOG%"
  ::popd & exit /B 0

  :: operate within this module's directory
  pushd "%~dp0"
  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] working in %cd%

  ::set _mod_util=..\..\util
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
  ::call "%_mod_util%\read-config" %_mod_name% _mod_enabled
  ::if not "%_mod_enabled%" == "true" (
  ::  call "%_mod_util%\log" "[%_mod_name%] module not enabled" "%_LOG%"
  ::  popd & exit /B 0
  ::)

  call "%_mod_util%\log" "[%_mod_name%] started module setup" "%_LOG%"
  mkdir "%_mod_output%"

  :: TODO: update tool(s) and remove this check if module is cross-architecture
  :: check for 32 or 64 bit operating system

  :: the -p lists processes running in logon sessions
  if exist "%PROGRAMFILES(X86)%" (
    set _logonsessions=%_mod_tools%\logonsessions64.exe
    :: PsLoggedOn shows which registered user is logged in
    set _psloggedon=%_mod_tools%\PsLoggedon64.exe
  ) else (
    set _logonsessions=%_mod_tools%\logonsessions.exe
    set _psloggedon=%_mod_tools%\PsLoggedon.exe
  )

  ::set _querysession=qwinsta
  ::set _queryuser=quser
  ::echo "%_querysession%"

  call:module
  goto:eof

  :module
  :: TODO: list TODO items
  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  echo "%_logonsessions%"
  call "%_mod_util%\log" "[%_mod_name%] collecting all active sessions" "%_LOG%"
  call"%_mod_util%\exec" "%_logonsessions% -c -p" "%_mod_output%\logonsessions.log" "%_mod_name%"
  
  echo "%_psloggedon%"
  call "%_mod_util%\log" "[%_mod_name%] collecting information about user logged on" "%_LOG%"
  call"%_mod_util%\exec" "%_psloggedon% -accepteula" "%_mod_output%\psloggedon.log" "%_mod_name%"

  ::query session shows all active sessions (need special permission for more)

  ::echo "qwinsta/counter"
  ::call "%_mod_util%\log" "[%_mod_name%] querying all active sessions" "%_LOG%"
  ::call"%_mod_util%\exec" "qwinsta/counter" "%_mod_output%\querysessions.log" "%_mod_name%"
  :: query user displays information about the user logged on
  :: specifically the name of user, name of session, session id, state of session, idle time, date and time logged on

  ::call "%_mod_util%\log" "[%_mod_name%] querying all user sessions on server" "%_LOG%"
  ::call"%_mod_util%\exec" "quser" "%_mod_output%\queryuser.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%" 

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
