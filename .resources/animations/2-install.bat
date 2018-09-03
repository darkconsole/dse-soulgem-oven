@ECHO OFF

SET COPYTO=..\..\meshes\actors\character\animations\dse-soulgem-oven

echo.
echo Copying to mod directory...
echo %COPYTO%
echo.

FOR %%F in (hkx\*.HKX) DO (
	echo ^>^> %%F
	xcopy /Y /I /Q %%F %COPYTO% > nul
)

echo.
pause