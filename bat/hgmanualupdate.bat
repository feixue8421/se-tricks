@ECHO OFF
SETLOCAL

REM hg manual update to avoid file collision on windows.

ECHO This command is deprecated and please use HGMANUALUPDATE.ps1 instead!
GOTO :DONE

hg pull

ECHO Start manual update at %time%

IF "%~1" == "" (
    SET rev=tip
) ELSE (
    SET rev=%~1
)

ECHO update to %rev%

hg debugsetparents %rev%
hg debugrebuildstate
hg revert --no-backup -I **/*.h -I **/*.hh -I **/*.hpp -I **/*.c -I **/*.cc -I **/*.cpp -I **/makefile -I **/*.xml -I **/*.json

ECHO Finish manual update at %time% !!

:DONE
ENDLOCAL
EXIT /B 0
