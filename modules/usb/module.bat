@echo off
setlocal enableextensions enabledelayedexpansion

:: name: usb
:: version: 1.0.0
:: author: Clay Mudter (clay.mudter@wustl.edu)
:: description: collects persistent, processed data about usb devices which have been used on the current machine using a 3-rd party tool called USBDeview
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: persistent, processed

set _mod_name=usb

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
    set _usbdeview=%_mod_tools%\usbdeview-x64\USBDeview.exe
  ) else (
    set _usbdeview=%_mod_tools%\usbdeview\USBDeview.exe
  )

  call:module
  goto:eof

:module

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  :: calls usbdeview with the proper command line arguments, sorted by decreasing registry time in a csv file
 call "%_mod_util%\exec" "%_usbdeview% /DisplayDisconnected 1 /DisplayNoPortSerial 1 /DisplayNoDriver 1 /RetrieveUSBPower /MarkConnectedDevices 1 /AddExportHeaderLine 1 /sort ~10 /scomma ""%_mod_output%\usbhistory.csv""" "%_mod_output%\usbhistory.log" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
