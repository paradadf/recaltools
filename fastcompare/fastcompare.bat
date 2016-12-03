@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=03.12.2016
title fastcompare ver. !releaseDate!

rem Show folder names in current directory
echo List of available folders for comparison:
for /d %%a in (*) do (
set /a count+=1
set mapArray[!count!]=%%a
echo !count!: %%a
)
echo.

:oldFolder
rem Select old folder
echo Which one is the old folder?
set /p "oldFolder=#: "
if exist !mapArray[%oldFolder%]! goto newFolder
echo Incorrect input & echo. & goto oldFolder

:newFolder
rem Select new folder
echo Which one is the new folder you want to compare?
set /p "newFolder=#: "
if "!newFolder!"=="!oldFolder!" echo You selected the same folder as before^^! & goto newFolder
if exist !mapArray[%newFolder%]! goto compareFolders
echo Incorrect input & echo. & goto newFolder

:compareFolders
rem Look for missing and modified files
title Comparing !mapArray[%oldFolder%]! with !mapArray[%newFolder%]!...
echo.
for /f "delims=" %%f in ('dir /b /a-d "%~dp0!mapArray[%newFolder%]!"') do (
	if exist "!mapArray[%oldFolder%]!\%%f" (
		fc !mapArray[%oldFolder%]!\* !mapArray[%newFolder%]!\*
		if errorlevel 1 echo %%f >> modified_files.txt
	) else (
		echo %%f >> missing_in_!mapArray[%oldFolder%]!.txt
	)
)

for /f "delims=" %%f in ('dir /b /a-d "%~dp0!mapArray[%oldFolder%]!"') do (
	if not exist "!mapArray[%newFolder%]!\%%f" echo %%f >> missing_in_!mapArray[%newFolder%]!.txt
)

title fastcompare ver. !releaseDate! - Comparison finished!
pause >nul