@ECHO OFF
SETLOCAL
:: Run this batch before calling install.bat

REM stop ProAgent service
NET STOP ProAgent 2>NUL

REM config ProAgent service to be disabled
SC CONFIG ProAgent start= disabled

REM kill ProAgent related programs
TASKKILL /F /T /IM pvservice.exe
TASKKILL /F /T /IM proagent.exe
TASKKILL /F /T /IM PvTrcMon.exe

ENDLOCAL
@ECHO ON
