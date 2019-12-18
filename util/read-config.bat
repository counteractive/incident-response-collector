@echo off
:: no setlocal, as this explicitly sets variables

:: read-config.bat <key> <value-variable>
:: sets <value-variable> to value for <key> in %_CONFIG%, or empty string if not found

:: _CONFIG is set here, not in main.bat
set _CONFIG=%~dp0..\config.ini

for /F "eol=# tokens=1,2* delims==" %%i in ('findstr /B /I /L "%~1=" "%_CONFIG%"') do (
  set "%~2=%%~j"
)
