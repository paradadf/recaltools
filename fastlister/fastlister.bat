@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=16.12.2016
title fastlister ver. !releaseDate!

rem List of excluded extensions
set excluded=.xml .txt

:listFolders
rem Show folder names in current directory
echo Available folders for listing:
for /d %%a in (*) do (
set /a count+=1
set mapArray[!count!]=%%a
echo !count!: %%a
)

:checkFolders
if not exist !mapArray[1]! cls & echo No folders found on current directory^^! & goto SUB_folderBrowser
if !count! gtr 1 set /a browser=!count!+1 & echo.!browser!: Open Folder Browser? & goto whichFolder
if !count! equ 1 echo. & set /p "oneFolder=List the content of !mapArray[1]!? [Y/N]: "
if /i "!oneFolder!"=="y" (set whichFolder=1 & goto validFolders) else goto SUB_folderBrowser

:whichFolder
echo.
rem Select folder(s) to be listed
echo The content of which folder(s) do you want to list? All? Choose !browser! to change directory.
set /p "whichFolder=#: "
if !whichFolder! equ !browser! goto SUB_folderBrowser
if /i not "%whichFolder%"=="all" goto validFolders
	set "folders="
	for /f "delims=" %%f in ('dir /b /a:d') do set folders=!folders! "%%f"
	goto outputFolder

:validFolders
rem Create string containing all valid corresponding names
set "folders="
set /a count1=0
for %%n  in (%whichFolder%) do (
	if exist !mapArray[%%n]! (set folders=!folders! "!mapArray[%%n]!" & set /a count1+=1) else echo %%n is not a valid number^^!
)

rem Check if input matched at least one folder
if %count1% gtr 0 goto outputFolder
echo Your input did not match any folder, try again^^! & echo. & goto whichFolder

:outputFolder
rem Create output folder
set destFolder=bestLists
if not exist %~dp0%destFolder% md %~dp0%destFolder%

:listContent
echo.
title fastlister ver. !releaseDate! - Creating lists...
for /d %%f in (%folders%) do (
	cd %%~f && echo Scanning %%~f...
	dir /b /a:-d /o:en 2>nul | findstr /v /i "%excluded%" >> "%~dp0%destFolder%\%%~f.txt"
	cd ..
)

rem Detect and delete empty files on output folder
echo.
for %%f in ("%~dp0%destFolder%\*") do (
	if %%~zf equ 0 echo %%~nf has no elements to list. & del "%%f"
)

rem Delete output folder if empty
echo.
dir /a-d "%~dp0%destFolder%\*" >nul 2>nul && (echo Find the lists inside bestLists folder^^!) || (rd "%~dp0%destFolder%" & echo No lists created^^!)

title fastlister ver. !releaseDate! - Scanning directories finished^^!

popd & pause >nul & exit

:SUB_folderBrowser
if !count! lss 2 set /p "openBrowser=Open Folder Browser? [Y/N]: "
if !count! lss 2 (
	if not "!openBrowser!"=="y" exit
)
set count=0 & echo Opening Folder Browser... & echo.

rem PowerShell-Subroutine to open a Folder Browser
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please choose a folder.',0,0).self.path""
for /f "usebackq delims=" %%i in (`powershell %psCommand%`) do set "newRoot=%%i"

rem Change working directory
cls & pushd !newRoot! & goto listFolders