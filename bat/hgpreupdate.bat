@ECHO OFF
SETLOCAL

REM preupdate hooker to handle file collision on windows.

SET PYTHON=C:\Users\y6wu\AppData\Local\Programs\Python\Python37\python.exe
SET PREUPDATE=C:\Repository\se-tricks\python\hgext\preupdate.py

ECHO Start to check file collision...
REM hg manifest tip | %PYTHON% %PREUPDATE%
REM IF %ERRORLEVEL% NEQ 0 (
REM     ECHO Errors detected during checking, errorlevel %ERRORLEVEL%
REM     ENDLOCAL
REM     EXIT /B 1
REM )

SET HG="C:\Program Files (x86)\Mercurial\hg.exe"

%HG% debugsetparents tip
%HG% debugrebuildstate

FOR /F "usebackq tokens=*" %%A IN (`%HG% manifest tip`) DO (
    IF EXIST %%A (
        ECHO %%A exist, and not update
    ) ELSE (
        hg revert %%A
    )
)

ECHO Finish checking file collision!!
ENDLOCAL
EXIT /B 0
