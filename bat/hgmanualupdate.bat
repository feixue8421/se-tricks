@ECHO OFF
SETLOCAL

REM hg manual update to avoid file collision on windows.

ECHO Start manual update ...

IF "%~1" == "" (
    SET rev=tip
) ELSE (
    SET rev=%~1
)

hg pull
hg debugsetparents %rev%
hg debugrebuildstate
hg revert -I **/*.h -I **/*.hh -I **/*.hpp -I **/*.c -I **/*.cc -I **/*.cpp -I **/makefile -I **/*.xml -I **/*.json

ECHO Finish manual update!!
ENDLOCAL
EXIT /B 0
