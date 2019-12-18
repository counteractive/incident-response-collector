@echo off
setlocal enableextensions enabledelayedexpansion

:: timestamp.bat
:: sets _ISO8601 to current UTC time in ISO 8601 format (to the second)

for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do set %%x

:: 0-pad values
if "%Day:~1,1%" equ "" set Day=0!Day!
if "%Month:~1,1%" equ "" set Month=0!Month!
if "%Hour:~1,1%" equ "" set Hour=0!Hour!
if "%Minute:~1,1%" equ "" set Minute=0!Minute!
if "%Second:~1,1%" equ "" set Second=0!Second!

set _tmp=!Year!-!Month!-!Day!T!Hour!!Minute!!Second!Z
endlocal & set _ISO8601=%_tmp%
