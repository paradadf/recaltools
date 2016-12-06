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
if exist !mapArray[%newFolder%]! echo. & goto compareFolders
echo Incorrect input & echo. & goto newFolder

:compareFolders
rem Look for modified files
title Comparing !mapArray[%oldFolder%]! with !mapArray[%newFolder%]!...
for %%f in ("!mapArray[%newFolder%]!\*") do (
	if exist "!mapArray[%oldFolder%]!\%%~nxf" (
		set /a count1+=1
		fc "!mapArray[%oldFolder%]!\%%~nxf" "!mapArray[%newFolder%]!\%%~nxf" >nul || if "!count1!"=="1" echo Modified files:
		if errorlevel 1 echo %%~nxf >> modified_files.txt & set /a count2+=1 & echo %%~nxf
	)
)

rem Look for missing files in oldFolder
for %%f in ("!mapArray[%newFolder%]!\*") do (
	if not exist "!mapArray[%oldFolder%]!\%%~nxf" (
		set /a count3+=1
		if "!count3!"=="1" echo. & echo Files not present in !mapArray[%oldFolder%]!:
		echo %%~nxf >> missing_in_!mapArray[%oldFolder%]!.txt
		echo %%~nxf
	)
)

rem Look for missing files in newFolder
for %%f in ("!mapArray[%oldFolder%]!\*") do (
	if not exist "!mapArray[%newFolder%]!\%%~nxf" (
		set /a count4+=1
		if "!count4!"=="1" echo. & echo Files not present in !mapArray[%newFolder%]!:
		echo %%~nxf >> missing_in_!mapArray[%newFolder%]!.txt
		echo %%~nxf
	)
)
echo.

rem Results
echo Results:
if !count2! gtr 0 echo Modified files: !count2!
if !count3! gtr 0 echo Files not present in !mapArray[%oldFolder%]!: !count3!
if !count4! gtr 0 echo Files not present in !mapArray[%newFolder%]!: !count4!
if "!count2!!count4!!count6!"=="" echo !mapArray[%oldFolder%]! and !mapArray[%newFolder%]! are identical^^!
title fastcompare ver. !releaseDate! - Comparison finished!
pause >nul