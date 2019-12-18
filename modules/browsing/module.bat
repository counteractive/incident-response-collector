@echo off

:: name: browsing
:: version: 1.0.0
:: author: Chris Hendricks (chris@counteractive.net)
:: description: collects persistent, processed browsing data from various built-in and 3rd-party tools
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project.
::        3rd-party tools are used and/or shared per the terms of their respective licences.
::        See the NOTICE file at the root of this project for details.
:: tags: persistent, processed

set _mod_name=browsing

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
  mkdir "%_mod_output%\cache-chrome"
  mkdir "%_mod_output%\cache-mozilla"
  mkdir "%_mod_output%\cache-ie"

  :: check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set _browsinghistoryview=%_mod_tools%\browsinghistoryview-x64\BrowsingHistoryView.exe
  ) else (
    set _browsinghistoryview=%_mod_tools%\browsinghistoryview\BrowsingHistoryView.exe
  )
  set _chromecacheview=%_mod_tools%\chromecacheview\ChromeCacheView.exe
  set _mozillacacheview=%_mod_tools%\mozillacacheview\MozillaCacheView.exe
  set _iecacheview=%_mod_tools%\iecacheview\IECacheView.exe

  call:module
  goto:eof

:module
  :: TODO: factor out cache file collection into separate module (very slow)

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: browsing history view from all users, any time, all browsers, sorted by decreasing visit time, with csv output
  call "%_mod_util%\log" "[%_mod_name%] collecting browsing history" "%_LOG%"
  call "%_mod_util%\exec" "%_browsinghistoryview% /HistorySource 1 /VisitTimeFilterType 1 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /LoadSafari 1 /sort ~2 /scomma ""%_mod_output%\browsinghistoryview.csv""" "%_mod_output%\browsinghistoryview.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] collecting chrome cache metadata" "%_LOG%"
  call "%_mod_util%\exec" "%_chromecacheview% /scomma ""%_mod_output%\cache-chrome.csv""" "%_mod_output%\chromecacheview.log" "%_mod_name%"
  :: call "%_mod_util%\log" "[%_mod_name%] collecting chrome cache" "%_LOG%"
  :: call "%_mod_util%\exec" "%_chromecacheview% /copycache """" """" /CopyFilesFolder ""%_mod_output%\cache-chrome"" /UseWebSiteDirStructure 0" "%_mod_output%\chromecacheview-copy.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] collecting mozilla cache metadata" "%_LOG%"
  call "%_mod_util%\exec" "%_mozillacacheview% /scomma ""%_mod_output%\cache-mozilla.csv""" "%_mod_output%\mozillacacheview.log" "%_mod_name%"
  :: call "%_mod_util%\log" "[%_mod_name%] collecting mozilla cache" "%_LOG%"
  :: call "%_mod_util%\exec" "%_mozillacacheview% /copycache """" """" /CopyFilesFolder ""%_mod_output%\cache-mozilla"" /UseWebSiteDirStructure 0" "%_mod_output%\mozillacacheview-copy.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] collecting internet explorer cache metadata" "%_LOG%"
  call "%_mod_util%\exec" "%_iecacheview% /scomma ""%_mod_output%\cache-ie.csv""" "%_mod_output%\iecacheview.log" "%_mod_name%"
  :: call "%_mod_util%\log" "[%_mod_name%] collecting internet explorer cache" "%_LOG%"
  :: call "%_mod_util%\exec" "%_iecacheview% /copycache """" """" /CopyFilesFolder ""%_mod_output%\cache-ie"" /UseWebSiteDirStructure 0" "%_mod_output%\iecacheview-copy.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
