@ECHO OFF
SETLOCAL

REM synchronize folders between SSH server and local

SET WORKING=C:\repository
SET PYTHON=C:\Users\y6wu\AppData\Local\Programs\Python\Python37\python.exe

PUSHD C:\Repository\se-tricks\python
%PYTHON% sshsynchronizer.py
POPD

ENDLOCAL
EXIT /B 0
