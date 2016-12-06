@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=06.12.2016
title fastcompare ver. !releaseDate!

rem Show folder names in current directory
echo List of available folders for comparison:
for /d %%a in (*) do (
set /a count+=1
set mapArray[!count!]=%%a
echo !count!: %%a
)
if not exist !mapArray[1]! cls & echo No folders found on current directory^^! & pause >nul & goto:eof
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
for %%f in ("!mapArray[%newFolder%]!\*") do (
	if exist "!mapArray[%oldFolder%]!\%%~nxf" (
		set /a count1+=1
		fc "!mapArray[%oldFolder%]!\%%~nxf" "!mapArray[%newFolder%]!\%%~nxf" >nul || if "!count1!"=="1" echo Modified files: & echo %%~nxf
		if errorlevel 1 echo %%~nxf >> modified_files.txt
	) else (
		set /a count2+=1
		if "!count2!"=="1" echo. & echo Files not present in !mapArray[%oldFolder%]!:
		echo %%~nxf >> missing_in_!mapArray[%oldFolder%]!.txt
		echo %%~nxf
	)
)
echo.

for %%f in ("!mapArray[%oldFolder%]!\*") do (
	if not exist "!mapArray[%newFolder%]!\%%~nxf" echo %%~nxf >> missing_in_!mapArray[%newFolder%]!.txt
	set /a count3+=1
	if "!count3!"=="1" echo Files not present in !mapArray[%newFolder%]!:
	if not exist "!mapArray[%newFolder%]!\%%~nxf" echo %%~nxf
)

title fastcompare ver. !releaseDate! - Comparison finished!
pause >nul