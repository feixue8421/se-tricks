@ECHO OFF
SETLOCAL

REM change current working folder
PUSHD "%~dp0"

REM call preinstall.bat if exists
IF EXIST .\preinstall.bat CALL .\preinstall.bat

REM copy files to ProAgent folder
SET PROAGENT_ROOT=C:\ProAgent\
XCOPY /Y /I /E .\ProAgent\* "%PROAGENT_ROOT%"

REM restore working folder
POPD

REM make ProAgent start automatically after ATM boots.
SET AUTO_START_KEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SET AUTO_START_NAME=StartWincor
SET AUTO_START_VALUE="\"%PROAGENT_ROOT%startup.bat\""

REG ADD %AUTO_START_KEY% /v %AUTO_START_NAME% /f /d %AUTO_START_VALUE% >NUL

ENDLOCAL
@ECHO ON
