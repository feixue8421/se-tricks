@ECHO OFF
REM This script is to start ProAgent on ATM.
SETLOCAL ENABLEDELAYEDEXPANSION

SET PV_ROOT=%~dp0
SET Path=%Path%;%PV_ROOT%Bin
SET PROAGENT_DATA=%PV_ROOT%DATA
SET PV_DATA=%PROAGENT_DATA%

REM install products
CALL "%PV_ROOT%setup.bat"
IF %ERRORLEVEL% NEQ 0 (
    EXIT /B 1
)

REM adapt proagent
CALL "%PV_ROOT%adapt.bat"

REM running proagent
SET RUNNING_STATE=%PROAGENT_DATA%\running
IF EXIST "%RUNNING_STATE%.stop" (
    MOVE /Y "%RUNNING_STATE%.stop" "%RUNNING_STATE%.run"
)

:LOOP
SLEEP 10 >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    PING 127.0.0.1 -n 10 >NUL 2>&1
)

IF EXIST "%RUNNING_STATE%.update" (
    CALL :STOP_PROGS
    CALL "%PV_ROOT%update.bat" apply
    IF !ERRORLEVEL! NEQ 0 (
        ECHO [!DATE! !TIME!] update failed with !ERRORLEVEL! >>"%RUNNING_STATE%.update"
        MOVE /Y "%RUNNING_STATE%.update" "%RUNNING_STATE%.updatefailed"
    ) ELSE (
        MOVE /Y "%RUNNING_STATE%.update" "%RUNNING_STATE%.updateok"
    )
) ELSE IF EXIST "%RUNNING_STATE%.run" (
    CALL :START_PVTRCMON
    CALL :START_PROAGENT
) ELSE IF EXIST "%RUNNING_STATE%.stop" (
    GOTO :STOP
) ELSE (
    ECHO . >"%RUNNING_STATE%.run"
)

GOTO :LOOP

:START_PROAGENT
TASKLIST /FI "IMAGENAME eq proagent.exe" | FINDSTR /I proagent.exe
IF %ERRORLEVEL% NEQ 0 (
    START /MIN ProAgent
)
EXIT /B 0

:START_PVTRCMON
TASKLIST /FI "IMAGENAME eq PvTrcMon.exe" | FINDSTR /I PvTrcMon.exe
IF %ERRORLEVEL% NEQ 0 (
    START /MIN PvTrcMon 1D
)
EXIT /B 0

:STOP_PROGS
TASKKILL /F /T /IM proagent.exe
TASKKILL /F /T /IM PvTrcMon.exe
EXIT /B 0

:STOP
CALL :STOP_PROGS

ENDLOCAL
@ECHO ON
