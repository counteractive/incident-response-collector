@echo off
setlocal enableextensions

:: build utility with some *nix make conventions
:: inspired by this comment: https://superuser.com/a/717465

:: operate in this script's directory, even when on another drive
pushd "%~dp0"

if /I "%1" == "all" goto:all
if /I "%1" == "modules" goto:modules
if /I "%1" == "clean" goto:clean

:all
  call:modules
  goto:eof

:modules
  echo calling module makefiles, if any
  for /d %%G in (modules\*) do (
    if exist %%G\make.bat (
      echo calling %%G\make.bat
      call %%G\make.bat
    )
  )
  goto:eof

:clean
  echo cleaning output directory
  del /f /q /s .\output\* > NUL
  for /d %%G in (output\*) do rmdir /s "%%G"
  goto:eof
