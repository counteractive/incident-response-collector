@echo off
setlocal enableextensions

:: build utility with some *nix make conventions
:: inspired by this comment: https://superuser.com/a/717465

if /I "%1" == "all" goto:all
if /I "%1" == "clean" goto:clean

:all
  pushd "%~dp0"
  :: download sysinternals utilities (not distributed with this package to comply with license)
  echo downloading sysinternals tools
  mkdir "tools\sysinternals"
  set _targets=list.exe each.exe executable.exe here.exe
  for %%G in (%_targets%) do (
    if exist "tools\sysinternals\%%G" (
      echo %%G already exists at tools\sysinternals\%%G
    ) else (
      echo downloading %%G
      "..\..\util\curl.exe" --insecure https://live.sysinternals.com/%%G -o "tools\sysinternals\%%G"
    )
  )
  popd
  goto:eof

:clean
  :: TODO: consider removing downloaded (sysinternals) tools
  goto:eof
