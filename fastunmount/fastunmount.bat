@echo off
color 3f
set releaseDate=02.01.2017
title fastunmount ver. %releaseDate%

rem List all mapped network drives
net use

rem Disconnect selected network drives
echo Which drive(s) do you want to unmount? All? (Ex. "z")
set /p whichDrives=
if /i "%whichDrives%"=="all" echo. & net use * /delete /yes & pause & goto:eof

echo.
for %%a in (%whichDrives%) do (
	if exist %%a:\ net use %%a: /delete
)

title fastunmount ver. %releaseDate% - Unmounting finished!
pause >nul
