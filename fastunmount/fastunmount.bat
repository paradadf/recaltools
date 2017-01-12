@echo off
color 3f
set releaseDate=12.01.2017
title fastunmount ver. %releaseDate%

rem List all mapped network drives
net use

rem Disconnect selected network drives
echo Which drive(s) do you want to unmount? All? (Ex. "z")
set /p whichDrives=
if /i not "%whichDrives%"=="all" echo. & goto selectedDrives

echo.

for /F "tokens=1,2,3" %%a in ('net use^| find "\\"') do (
  echo.Unmounting %%c from drive letter %%b
  net use %%b /D
)

:selectedDrives
rem Show warning for incorrect inputs
for %%a in (%whichDrives:all=%) do (
	if not exist %%a: echo %%a: not found!
)
echo.

for /F "tokens=1,2,3" %%a in ('net use^| find "\\"') do (
	for %%d in (%whichDrives%) do (
		if /I "%%d:"=="%%b" (
			echo.Unmounting %%c from drive letter %%b
			net use %%b /D
		)
	)
)

title fastunmount ver. %releaseDate% - Unmounting finished!
pause >nul
