@ECHO OFF
REM This script is to install ProAgent on ATM. Please DO NOT execute the script separately. It will be called within startup.bat script.
SETLOCAL
SET PROAGENT_CONFIG=%PV_ROOT%Config
SET PROAGENT_INSTALL_STATE=%PROAGENT_DATA%\proagent

REM check if ProAgent has been installed already
SET PROAGENT_INSTALLED="%PROAGENT_INSTALL_STATE%.installed"
IF EXIST %PROAGENT_INSTALLED% (
    ECHO ProAgent Already Installed
    EXIT /B 0
)

SET PROAGENT_SETUP_LOG="%PROAGENT_DATA%\setup.log"
CALL :PRINT_AND_RECORD "ProAgent Installation Started..."

REM record installing state
SET PROAGENT_INSTALLING="%PROAGENT_INSTALL_STATE%.installing"
ECHO. > %PROAGENT_INSTALLING%

REM import standard reg files into registry
CALL :PRINT_AND_RECORD "Start Importing regs in Standard Folder..."
CALL :IMPORT_REGS "%PROAGENT_CONFIG%\Standard"
IF %ERRORLEVEL% NEQ 0 (
    CALL :PRINT_AND_RECORD "Failed to Import Regs of Standard!"
    GOTO :POINT_FAIL
)
CALL :PRINT_AND_RECORD "Finish Importing regs in Standard Folder!"

REM import customer reg files into registry
CALL :PRINT_AND_RECORD "Start Importing regs in Customer Folder..."
CALL :IMPORT_REGS "%PROAGENT_CONFIG%\Customer"
IF %ERRORLEVEL% NEQ 0 (
    CALL :PRINT_AND_RECORD "Failed to Import Regs of Customer!"
    GOTO :POINT_FAIL
)
CALL :PRINT_AND_RECORD "Finish Importing regs in Customer Folder!"

REM copy files into ProAgent folder
CALL :PRINT_AND_RECORD "Start Copying files..."
PUSHD "%PROAGENT_DATA%"
XCOPY /Y /I /E "%PROAGENT_CONFIG%\Standard\*" "%PV_ROOT%" /EXCLUDE:copyexcludes.txt
XCOPY /Y /I /E "%PROAGENT_CONFIG%\Customer\*" "%PV_ROOT%" /EXCLUDE:copyexcludes.txt
POPD
CALL :PRINT_AND_RECORD "Finish Copying files!"

REM make ProAgent start automatically after ATM boots.
SET AUTO_START_KEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SET AUTO_START_NAME=StartWincor
SET AUTO_START_VALUE="\"%PV_ROOT%startup.bat\""

REG ADD %AUTO_START_KEY% /v %AUTO_START_NAME% /f /d %AUTO_START_VALUE% >NUL
IF %ERRORLEVEL% NEQ 0 (
    CALL :PRINT_AND_RECORD "Failed to Add ProAgent Startup Script to Windows Run Registry!"
    GOTO :POINT_FAIL
)

REM execute postinstall.bat if exist, and ignore the execution result
IF EXIST "postinstall.bat" (
    CALL :PRINT_AND_RECORD "ProAgent Installation Postinstall..."
    CALL "postinstall.bat"
    IF %ERRORLEVEL% NEQ 0 (
        CALL :PRINT_AND_RECORD "ProAgent Installation Postinstall Failed: %ERRORLEVEL%"
    ) else (
        CALL :PRINT_AND_RECORD "ProAgent Installation Postinstall Succeeded."
    )
)

REM ProAgent installed
GOTO :POINT_SUCCESS

:POINT_FAIL
DEL /F /Q %PROAGENT_INSTALLING%
@ECHO ON
@EXIT /B %ERRORLEVEL%

:POINT_SUCCESS
REM mark ProAgent to be installed
MOVE /Y %PROAGENT_INSTALLING% %PROAGENT_INSTALLED%
CALL :PRINT_AND_RECORD "ProAgent Installation Finished Successfully!"
ENDLOCAL
@ECHO ON
@EXIT /B 0

:PRINT_AND_RECORD
ECHO %~1
ECHO [%DATE% %TIME%] %~1 >> %PROAGENT_SETUP_LOG%
EXIT /B 0

REM import regs into Registry
:IMPORT_REGS
SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%i IN ("%~1\*.reg") DO (
    REG IMPORT "%%i" >NUL
    IF !ERRORLEVEL! NEQ 0 (
        CALL :PRINT_AND_RECORD "Import %%i Failed, Error: !ERRORLEVEL!"
        ENDLOCAL
        EXIT /B 1
    )
)
ENDLOCAL
EXIT /B 0
