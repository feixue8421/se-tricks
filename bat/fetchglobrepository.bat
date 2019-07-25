@ECHO OFF
SETLOCAL

REM fetch GLOB repository from SSH server and extract to REPOSITORY folder

SET WORKING=C:\repository
SET CLEAN=YES
SET PYTHON=C:\Users\y6wu\AppData\Local\Programs\Python\Python37\python.exe
SET FETCHER=fetchglobrepository.py
SET EXTRACTER=extractzip.bat

PUSHD C:\Repository\se-tricks\python
%PYTHON% fetchglobrepository.py
POPD

CALL %EXTRACTER%

ENDLOCAL
EXIT /B 0
