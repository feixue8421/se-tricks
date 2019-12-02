@ECHO OFF
SETLOCAL

REM preupdate hooker to handle file collision on windows.

SET PYTHON=C:\Users\y6wu\AppData\Local\Programs\Python\Python37\python.exe
SET PREUPDATE=C:\Repository\se-tricks\python\hgext\preupdate.py

ECHO Start to check file collision...
hg manifest tip | %PYTHON% %PREUPDATE%
IF %ERRORLEVEL% NEQ 0 (
    ECHO Errors detected during checking, errorlevel %ERRORLEVEL%
    ENDLOCAL
    EXIT /B 1
)

ECHO Finish checking file collision!!
ENDLOCAL
EXIT /B 0
