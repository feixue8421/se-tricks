@ECHO OFF
SETLOCAL
:: Run this batch to stop proagent

SET PV_ROOT=%~dp0
SET PROAGENT_DATA=%PV_ROOT%DATA

SET RUNNING_STATE=%PROAGENT_DATA%\running

IF EXIST "%RUNNING_STATE%.run" (
    MOVE /Y "%RUNNING_STATE%.run" "%RUNNING_STATE%.stop"
) ELSE (
    ECHO. >"%PROAGENT_DATA%\running.stop"
)

ENDLOCAL
@ECHO ON
