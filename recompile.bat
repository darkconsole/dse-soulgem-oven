@ECHO OFF

SET Compiler=C:\Games\MOSSE\mo-script-compile.bat
SET Output=C:\Games\MOSSE\mods\dse-soulgem-oven

FOR /R "%Output%\Scripts\Source" %%F IN (*.psc) DO (
	CALL %Compiler% %%~nF %Output%
	SLEEP 6
)
