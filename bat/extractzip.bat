@ECHO OFF
SETLOCAL

REM extract zip file to specified folder

IF "%WORKING%" EQU "" SET WORKING=.

PUSHD C:\Program Files\7-Zip

FOR %%i IN ("%WORKING%\*.zip") DO (
    ECHO Processing file: %%i
    7z x "%%i" -o"%WORKING%" -y >NUL
    ECHO Extracted successfully!

    IF "%CLEAN%" EQU "YES" DEL "%%i" /F /S /Q
)

POPD

ENDLOCAL
EXIT /B 0
