@echo off
setlocal enableextensions enabledelayedexpansion

:: name: registry
:: version: 1.0.0
:: author: Ferris Atassi
:: description: Collects registry information of users and the system.
:: notes: this module is licensed per the terms in the LICENSE file at the root of this project. 3rd-party tools are used and/or shared per the terms of their respective licences. See the NOTICE file at the root of this project for details.
:: tags: users, registry hives, profiles

:: TODO: update module-name
set _mod_name= registry

:setup
  :: TODO: remove when implemented
  call "%_mod_util%\log" "[%_mod_name%] module not implented" "%_LOG%"
  popd & exit /B 0

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

  :: TODO: update tool(s) and remove this check if module is cross-architecture
  :: check for 32 or 64 bit operating system
 :: if exist "%PROGRAMFILES(X86)%" (
 ::   set _tool=%_mod_tools%\[tool-name-64bit.exe]
 ::) else (
 :: set _tool=%_mod_tools%\[tool-name-32bit.exe]
 :: )

  call:module
  goto:eof

:module
  :: TODO: Port from ir-rescue

  call "%_mod_util%\log" "[%_mod_name%] started module" "%_LOG%"

  ::TODO: build command(s) based on the details of the module and its tool(s), see example below:
  if %creg% equ true(if %RUN% equ false mkdir %REG% )
  if %creg-sys% equ true (
    if %RUN% equ true (
      call:cmd %REG%\log "%RCP% /FileNamePath:%SystemRoot%\System32\config\SAM /OutputPath:%REG%\sys"
			call:cmd %REG%\log "%RCP% /FileNamePath:%SystemRoot%\System32\config\SECURITY /OutputPath:%REG%\sys"
			call:cmd %REG%\log "%RCP% /FileNamePath:%SystemRoot%\System32\config\SOFTWARE /OutputPath:%REG%\sys"
			call:cmd %REG%\log "%RCP% /FileNamePath:%SystemRoot%\System32\config\SYSTEM /OutputPath:%REG%\sys"
      ren %REG%\sys\SAM SAM-live
			ren %REG%\sys\SECURITY SECURITY-live
			ren %REG%\sys\SOFTWARE SOFTWARE-live
			ren %REG%\sys\SYSTEM SYSTEM-live
    ) else (mkdir %REG%\sys & set /A it+=1, itt+=4)
    if %creg-vss% equ true (
      for /L %%i in (1,1,%iv%) do (
				if /I %SYSROOTD% equ !vsscd[%%i]! (
					if %RUN% equ true (
						call:cpf %REG%\log "!vssc[%%i]!%SYSROOTP%\System32\config\SAM" "%REG%\sys\SAM-!vsscf[%%i]!"
						call:cpf %REG%\log "!vssc[%%i]!%SYSROOTP%\System32\config\SECURITY" "%REG%\sys\SECURITY-!vsscf[%%i]!"
						call:cpf %REG%\log "!vssc[%%i]!%SYSROOTP%\System32\config\SOFTWARE" "%REG%\sys\SOFTWARE-!vsscf[%%i]!"
						call:cpf %REG%\log "!vssc[%%i]!%SYSROOTP%\System32\config\SYSTEM" "%REG%\sys\SYSTEM-!vsscf[%%i]!"
					) else set /A itt+=4
				)
			)
    )
  )
  if %creg-user% equ true (
		set /A tmp=0
		if %RUN% equ true (
			call:header "user registry hives"
			for /L %%i in (1,1,%ip%) do (
				call:cmdn %REG%\log "%RCP% /FileNamePath:!uprofiles[%%i]!\NTUSER.dat /OutputPath:%REG%\user\"
				%RCP% /FileNamePath:"!uprofiles[%%i]!\NTUSER.dat" /OutputPath:%REG%\user\ >> %REG%\log.txt 2>&1
				call:cmdn %REG%\log "%RCP% /FileNamePath:!uprofiles[%%i]!\AppData\Local\Microsoft\Windows\UsrClass.dat /OutputPath:%REG%\user\"
				%RCP% /FileNamePath:"!uprofiles[%%i]!\AppData\Local\Microsoft\Windows\UsrClass.dat" /OutputPath:%REG%\user\ >> %REG%\log.txt 2>&1
				call:attren "%REG%\user\NTUSER.dat" "NTUSER-!usersp[%%i]!-live.dat"
				call:attren "%REG%\user\UsrClass.dat" "UsrClass-!usersp[%%i]!-live.dat"
			)
		) else (mkdir %REG%\user & set /A it+=1, itt+=2*%ip%, tmp+=%ip%)
		if %creg-vss% equ true (
			for /L %%i in (1,1,%ip%) do (
				for /L %%a in (1,1,%iv%) do (
					if /I %UPROFILED% equ !vsscd[%%a]! (
						if %RUN% equ true (
							call:xcp %REG%\log "!vssc[%%a]!!uprofiles[%%i]:~2!\NTUSER.dat" "%REG%\user"
							call:attren "%REG%\user\NTUSER.dat" "NTUSER-!usersp[%%i]!-!vsscf[%%a]!.dat"
							call:xcp %REG%\log "!vssc[%%a]!!uprofiles[%%i]:~2!\AppData\Local\Microsoft\Windows\UsrClass.dat" "%REG%\user"
							call:attren "%REG%\user\UsrClass.dat" "UsrClass-!usersp[%%i]!-!vsscf[%%a]!.dat"
						) else (set /A itt+=2, tmp+=1)
					)
				)
			)
		)
	)
	if %creg-text% equ true (
		if %RUN% equ true (
			call:header "registry hives" "exporting"
			call:cmd %REG%\log "reg export HKCR %REG%\txt\hkcr.reg /Y"
			call:cmd %REG%\log "reg export HKLM %REG%\txt\hklm.reg /Y"
			call:cmd %REG%\log "reg export HKU %REG%\txt\hku.reg /Y"
		) else (mkdir %REG%\txt & set /A it+=1, itt+=3)
	)

	goto:eof

  call "%_mod_util%\log" "[%_mod_name%] obtaining user registry" "%_LOG%"

  call "%_mod_util%\exec" "command" "output-file" "tag (usually %_mod_name%)" "%_mod_name%"

  call "%_mod_util%\log" "[%_mod_name%] completed module" "%_LOG%"

  if "%_DBG%" == "true" echo DEBUG: [%_mod_name%] leaving %cd%
  popd
  goto:eof
