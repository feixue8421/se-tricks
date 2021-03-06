@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET TASKTITLE="RUN.WITH.TIMEOUT"
SET LOOPS=3
SET INTERVAL=60
SET PROGRAMS=python

START %TASKTITLE% %PROGRAMS%

ECHO START AT %DATE% %TIME%

:LOOP
ECHO CHECKING %LOOPS% WITH INTERVAL %INTERVAL% ...
PING 127.0.0.1 -n %INTERVAL% >NUL 2>&1
SET /A LOOPS=%LOOPS%-1
IF %LOOPS% NEQ 0 (
    GOTO :LOOP
)

ECHO STOP AT %DATE% %TIME%
TASKKILL /F /FI "WINDOWTITLE eq %TASKTITLE%"

ENDLOCAL
@ECHO ON
@EXIT /B 0
