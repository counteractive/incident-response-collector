@echo off

:: name: TODO
:: version: TODO
:: author: TODO
:: description: TODO
:: notes: TODO (licence, notice, etc.)
:: tags: TODO

:: TODO: replace items in square-brackets ([]); other defaults should be good for most modules
set MODULE_NAME=disk-image
set MODULE_DIR=%MODULES%\%MODULE_NAME%
set MODULE_OUTPUT=%OUTPUT%\%MODULE_NAME%
set _module_tools=%MODULE_DIR%\tools

:setup
  :: TODO: remove when implemented
  call %UTIL%\log "[%MODULE_NAME%] module not implented"
  popd & exit /B 0

  :: confirm this module is enabled
  call %UTIL%\read-config %MODULE_NAME% _module_enabled
  if not "!_module_enabled!" == "true" (
    call %UTIL%\log "[%MODULE_NAME%] module not enabled"
    popd & exit /B 0
  )

  call %UTIL%\log "[%MODULE_NAME%] started module setup"
  mkdir %MODULE_OUTPUT%

  :: TODO: remove this check if module is cross-architecture
  :: check for 32 or 64 bit operating system
  if exist "%PROGRAMFILES(X86)%" (
    set _tool=%_module_tools%\[tool-name-64bit.exe]
  ) else (
    set _tool=%_module_tools%\[tool-name-32bit.exe]
  )

  call:module
  goto:eof

:module
  :: log header
  call %UTIL%\log "[%MODULE_NAME%] started module"

  ::TODO: build command(s) based on the details of the module and its tool(s), see example below:
  call %UTIL%\timestamp
  call %UTIL%\exec "<out-path-here>" "<command-details-here>"

  :: log footer
  call %UTIL%\log "[%MODULE_NAME%] completed module"

  goto:eof
