@ECHO OFF
SETLOCAL
:: Run this batch to update ProAgent.

SET PV_ROOT=%~dp0
SET PROAGENT_DATA=%PV_ROOT%DATA

IF [%1] == [] (
    ECHO. >"%PROAGENT_DATA%\running.update"
) ELSE (
    DEL /F /Q "%PROAGENT_DATA%\proagent.installed" 2>NUL
    PUSHD "%PV_ROOT%"
    CALL setup.bat && CALL adapt.bat
    POPD
)

ENDLOCAL
@ECHO ON
