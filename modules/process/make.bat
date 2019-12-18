@echo off
setlocal enableextensions

:: build utility with some *nix make conventions
:: inspired by this comment: https://superuser.com/a/717465

if /I "%1" == "all" goto:all
if /I "%1" == "clean" goto:clean

:all
  :: download sysinternals utilities (not distributed with this package to comply with license)
  echo downloading sysinternals tools
  set _targets=handle.exe handle64.exe pslist.exe pslist64.exe Listdlls.exe Listdlls64.exe PsService.exe PsService64.exe
  for %%G in (%_targets%) do (
    if exist "%~dp0tools\sysinternals\%%G" (
      echo %%G already exists at %~dp0tools\sysinternals\%%G
    ) else (
      echo downloading %%G
      "%~dp0..\..\util\curl.exe" --insecure https://live.sysinternals.com/%%G -o "%~dp0tools\sysinternals\%%G"
    )
  )
  goto:eof

:clean
  :: TODO: consider removing downloaded (sysinternals) tools
  goto:eof
