@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET AGENT_TID="%PROAGENT_DATA%\proagent.tid"
SET AGENT_TID_NEW=%AGENT_TID:.tid=.tid_new%

REM adapt terminal id and cleanup events at changes

CALL :RETREIVE_PROAGENT_TID
IF NOT EXIST %AGENT_TID% (
    CALL :CLEAN_RUNNING_INFO
    MOVE /Y %AGENT_TID_NEW% %AGENT_TID%
) ELSE (
    FC %AGENT_TID% %AGENT_TID_NEW% >NUL 2>&1
    IF !ERRORLEVEL! NEQ 0 (
        CALL :CLEAN_RUNNING_INFO
        MOVE /Y %AGENT_TID_NEW% %AGENT_TID%
    ) ELSE (
        DEL /F /Q %AGENT_TID_NEW%
    )
)


REM adapt WOSA version and WOSA devices

ENDLOCAL
@ECHO ON
@EXIT /B 0

:CLEAN_RUNNING_INFO
DEL /F /Q "%PV_ROOT%\Event\Later\*" 2>NUL
DEL /F /Q "%PV_ROOT%\Event\Urgent\*" 2>NUL
DEL /F /Q "%PROAGENT_DATA%\Restart.dat" 2>NUL
EXIT /B 0

:RETREIVE_PROAGENT_TID
SETLOCAL ENABLEDELAYEDEXPANSION
SET TID_KEY="HKLM\SOFTWARE\Wincor Nixdorf\ProAgent\CurrentVersion\SSTP"
SET TID_ATTR=TerminalId
SET TID_VALUE=""

FOR /F "usebackq skip=4 tokens=2*" %%A IN (`REG QUERY %TID_KEY% /v %TID_ATTR% 2^>NUL`) DO SET TID_VALUE=%%B
FOR /F "tokens=1,2 delims=;" %%A IN ("%TID_VALUE%") DO (
    SET TID_KEY=%%A
    SET TID_ATTR=%%B
)
IF NOT "%TID_ATTR%"=="" (
    SET TID_VALUE=""
    SET TID_KEY="HKLM\%TID_KEY:HKLM\=%"
    FOR /F "usebackq skip=4 tokens=2*" %%A IN (`REG QUERY !TID_KEY! /v !TID_ATTR! 2^>NUL`) DO SET TID_VALUE=%%A
)

IF [%TID_VALUE%]==[""] (
    HOSTNAME >%AGENT_TID_NEW%
) ELSE (
    ECHO.%TID_VALUE% >%AGENT_TID_NEW%
)

ENDLOCAL
EXIT /B 0

