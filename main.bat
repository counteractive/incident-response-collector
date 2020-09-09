@echo off

:: incident-response-collector
:: Copyright (C) 2020 Counteractive Security

:: This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
:: You should have received a copy of the GNU General Public License in this package as LICENSE. If not, see <https://www.gnu.org/licenses/>.
:: 3rd-party tools called by this program are distributed and used in accordance with their respective licenses.  See the NOTICE.md file for details.

:setup
  :: operate in this script's directory, even when on another drive
  :: keep all subdirectories space-free
  pushd "%~dp0"

  set _DBG=false

  set _app_name=incident-response-collector
  set _app_ver=v0.1.0
  set _util=util
  set _modules=modules

  if /I "%1" == "--version" echo %_app_name% %_app_ver% && goto:eof
  if not "%1" == "" call:help && goto:eof

  :: check for administrator permissions
  fsutil dirty query %SYSTEMDRIVE% > NUL 2>&1
  if not %ERRORLEVEL% equ 0 (
    echo:
    echo %~nx0 requires administrator rights.
    call:help
    goto:eof
  )

  call "%_util%\timestamp"
  set _OUT=%~dp0output\%COMPUTERNAME%-%_ISO8601%
  set _LOG=%_OUT%\log.txt

  :: create output directory and touch logfile (util\log only logs to existing file)
  mkdir "%_OUT%"
  type nul > "%_LOG%"
  call "%_util%\log" "[%_app_name% %_app_ver%] created output directory at %_OUT%" "%_LOG%"
  call "%_util%\log" "[%_app_name% %_app_ver%] created log file at %_LOG%" "%_LOG%"

  call:main
  goto:eof

:main
  :: change codepage to UTF-8 to support filenames in multiple languages
	chcp 65001 > NUL 2>&1

  call "%_util%\log" "[%_app_name% %_app_ver%] started main" "%_LOG%"

  :: call modules in explicit order based on volatility
  call "%_modules%\memory-image\module"
  call "%_modules%\memory-files\module"
  call "%_modules%\network\module"
  call "%_modules%\process\module"
  call "%_modules%\filesystem\module"
  call "%_modules%\files\module"
  call "%_modules%\prefetch\module"
  call "%_modules%\system\module"
  call "%_modules%\autostart\module"
  call "%_modules%\activity\module"
  call "%_modules%\browsing\module"
  call "%_modules%\dirwalk\module"
  call "%_modules%\events\module"
  call "%_modules%\registry\module"
  call "%_modules%\usb\module"
  call "%_modules%\session\module"
  call "%_modules%\file_hashing\module"
  call "%_modules%\hash_checks\module"
  call "%_modules%\yara_scans\module"

  :: unimplemented
  :: call "%_modules%\disk-image\module"
  :: call "%_modules%\browser-cache-files\module"

  call "%_util%\log" "[%_app_name% %_app_ver%] ended main" "%_LOG%"
  goto:eof

:help
  echo:
  echo Usage: %~nx0 [OPTION]
  echo:
  echo Gather response data from this system using built-in and third-party tools. Requires administrator rights.
  echo Uses configuration in config.ini (or custom path in util\read-config.bat).
  echo:
  echo Options:
  echo:
  echo --help, -h, /?  display this help and exit
  echo --version       display version information and exit
  echo:
  echo For more information, or to report issues, visit https://github.com/counteractive/incident-response-collector.
  goto:eof
