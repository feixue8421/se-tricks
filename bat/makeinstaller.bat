REM prepare Data folder for installation
MD Data
XCOPY /Y /I /E ProAgent\*.* Data\ProAgent\
XCOPY /Y install.bat Data\
XCOPY /Y preinstall.bat Data\

REM package ProAgent folder
ProAgent\Bin\7z.exe a -r ProAgent.7z .\Data\*

REM make ProAgent installer
COPY /B /Y 7zsd_All.sfx+setup.7z.txt+ProAgent.7z ProAgentInstaller.exe

REM delete installation files
RD /S /Q Data
DEL /F /Q ProAgent.7z
