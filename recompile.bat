@ECHO OFF

SET Compiler=C:\Games\MOSSE\mo-script-compile.bat
SET Output=C:\Games\MOSSE\mods\dse-soulgem-oven

FOR /R "%Output%\Scripts" %%F IN (*) DO (
	call %Compiler% %%~nF %Output%
	TIMEOUT /t 10
)