@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=16.12.2016
title fastcompare ver. !releaseDate!

rem Set prefix for output files
set prefixMiss=missing_in_
set prefixMod=modified_files

:listFolders
rem Show folder names in current directory
echo List of available folders for comparison:
for /d %%a in (*) do (
set /a count+=1
set mapArray[!count!]=%%a
echo !count!: %%a
)

:checkFolders
if not exist !mapArray[1]! cls & echo No folders found on current directory^^! & goto SUB_folderBrowser
if !count! lss 2 cls & echo There is only one folder on the current directory to compare^^! & goto SUB_folderBrowser
if !count! gtr 2 set /a browser=!count!+1 & echo.!browser!: Open Folder Browser? & goto oldFolder
if !count! equ 2 echo. & set /p "twoFolders=Compare !mapArray[1]! with !mapArray[2]!? [Y/N]: "
if /i "!twoFolders!"=="y" (set "oldFolder=1" & set "newFolder=2" & goto modScan) else goto SUB_folderBrowser

:oldFolder
echo.
rem Select old folder
echo Which one is the old folder? Choose !browser! to change directory.
set /p "oldFolder=#: "
if !oldFolder! equ !browser! goto SUB_folderBrowser
if exist !mapArray[%oldFolder%]! goto newFolder
echo Incorrect input^^! & goto oldFolder

:newFolder
rem Select new folder
echo Which one is the new folder you want to compare?
set /p "newFolder=#: "
if "!newFolder!"=="!oldFolder!" echo You selected the same folder as before^^! & goto newFolder
if exist !mapArray[%newFolder%]! goto modScan
echo Incorrect input^^! & echo. & goto newFolder

:modScan
rem Scan for modified files or only missing files?
set /p "mod=Scan for modified files? [Y/N]: "
if "!mod!"=="y" (echo. & goto modFiles)
if "!mod!"=="n" goto missFiles
echo Incorrect input^^! & echo. & goto modScan

:modFiles
rem Look for modified files
title Comparing !mapArray[%oldFolder%]! with !mapArray[%newFolder%]!...
for %%f in ("!mapArray[%newFolder%]!\*") do (
	if exist "!mapArray[%oldFolder%]!\%%~nxf" (
		set /a count1+=1
		fc "!mapArray[%oldFolder%]!\%%~nxf" "!mapArray[%newFolder%]!\%%~nxf" >nul || if !count1! equ 1 echo Modified files:
		if errorlevel 1 echo %%~nxf >> "%~dp0!prefixMod!.txt" & set /a count2+=1 & echo %%~nxf
	)
)

:missFiles
rem Look for missing files in oldFolder
for %%f in ("!mapArray[%newFolder%]!\*") do (
	if not exist "!mapArray[%oldFolder%]!\%%~nxf" (
		set /a count3+=1
		if !count3! equ 1 echo. & echo Files not present in !mapArray[%oldFolder%]!:
		echo %%~nxf >> "%~dp0!prefixMiss!!mapArray[%oldFolder%]!.txt"
		echo %%~nxf
	)
)

rem Look for missing files in newFolder
for %%f in ("!mapArray[%oldFolder%]!\*") do (
	if not exist "!mapArray[%newFolder%]!\%%~nxf" (
		set /a count4+=1
		if !count4! equ 1 echo. & echo Files not present in !mapArray[%newFolder%]!:
		echo %%~nxf >> "%~dp0!prefixMiss!!mapArray[%newFolder%]!.txt"
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
popd & pause >nul & exit

:SUB_folderBrowser
if !count! lss 3 set /p "openBrowser=Open Folder Browser? [Y/N]: "
if !count! lss 3 (
	if not "!openBrowser!"=="y" exit
)
set count=0 & echo Opening Folder Browser... & echo.

rem PowerShell-Subroutine to open a Folder Browser
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please choose a folder.',0,0).self.path""
for /f "usebackq delims=" %%i in (`powershell %psCommand%`) do set "newRoot=%%i"

rem Change working directory
cls & pushd !newRoot! & goto listFolders