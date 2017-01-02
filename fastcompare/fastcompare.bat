@echo off
color 3f
set releaseDate=02.01.2017
title fastcompare ver. %releaseDate%

rem List of excluded extensions
set "excluded=.xml .txt"

rem Set prefix for output files
set prefixMiss=missing_in_
set prefixMod=modified_files

rem Set abbreviation
set "EDE=setlocal EnableDelayedExpansion"
set "DDE=setlocal DisableDelayedExpansion"

rem Set defaults to launch directory
set rootFolderOld=%~dp0
set rootFolderNew=%~dp0

:listFoldersOld
rem Show folder names in current directory
echo List of available folders for comparison:
set count=0
set count1=0
for /f "delims=: tokens=1*" %%a in ('dir /b /a:d /o:n ^| findstr /n "."') do (
	set "mapArray[%%a]=%%b"
	set "count=%%a"
	echo %%a: %%b
)

:checkFoldersOld
setlocal EnableDelayedExpansion
if not exist !mapArray[1]! cls & echo No folders found on current directory^^! & goto SUB_folderBrowser
if %count% gtr 0 set /a browser=%count%+1 & echo.!browser!: Open Folder Browser?
if %count% equ 2 echo. & set /p "twoFolders=Compare !mapArray[1]! with !mapArray[2]!? [Y/N]: "
if /i "%twoFolders%"=="y" (set "folderOld=!mapArray[1]!" & set "folderNew=!mapArray[2]!" & goto outputFiles) else goto oldFolder

:oldFolder
echo.
if exist !folderOld! goto listFoldersNew
rem Select old folder
set type=rootOld
echo Which one is the old folder? Choose %browser% to change directory.
set /p "oldFolder=#: "
if %oldFolder% equ %browser% goto SUB_folderBrowser
setlocal EnableDelayedExpansion
if exist !mapArray[%oldFolder%]! set "folderOld=!mapArray[%oldFolder%]!" & goto listFoldersNew
echo Incorrect input^^! & goto oldFolder

:listFoldersNew
setlocal DisableDelayedExpansion
rem Show folder names in current directory
if "%type%"=="rootNew" echo List of available folders for comparison:
for /f "delims=: tokens=1*" %%a in ('dir /b /a:d /o:n ^| findstr /n "."') do (
	set "mapArray1[%%a]=%%b"
	set "count1=%%a"
	if "%type%"=="rootNew" echo %%a: %%b
)

:checkFoldersNew
setlocal EnableDelayedExpansion
if not exist !mapArray1[1]! cls & echo No folders found on current directory^^! & goto SUB_folderBrowser
if "%type%"=="rootNew" set /a browser=%count1%+1 & echo.!browser!: Open Folder Browser? & goto newFolder

:newFolder
echo.
rem Select new folder
set type=rootNew
echo Which one is the new folder you want to compare? Choose %browser% to change directory.
set /p "newFolder=#: "
if %newFolder% equ %browser% goto SUB_folderBrowser
if "%rootFolderNew%!mapArray1[%newFolder%]!"=="%rootFolderOld%!folderOld!" (echo You selected the same folder as before^^! & goto newFolder)
if exist !mapArray1[%newFolder%]! set "folderNew=!mapArray1[%newFolder%]!" & goto outputFiles
echo Incorrect input^^! & echo. & goto newFolder

:outputFiles
set "outputMod=%~dp0%prefixMod%.txt"
set "outputOld=%~dp0%prefixMiss%!folderOld!.txt"
if "!folderOld!"=="!folderNew!" set "suffix=_^(2^)"
set "outputNew=%~dp0%prefixMiss%!folderNew!%suffix%.txt"

:modScan
echo.
rem Scan for modified files or only missing files?
set /p "mod=Scan for modified files? [Y/N]: "
if "%mod%"=="y" (echo. & goto modFiles)
if "%mod%"=="n" goto missFilesOld
echo Incorrect input^^! & goto modScan

:modFiles
rem Look for modified files
setlocal DisableDelayedExpansion
rem Use findstr /n "^" if exclusions cause problems
for /f "delims=: tokens=1*" %%a in ('dir /b /a-d /o:en "%rootFolderNew%%folderNew%\*" ^| findstr /v /i /n "%excluded%"') do (
	title fastcompare ver. %releaseDate% - Scanning %%b
	if exist "%rootFolderOld%%folderOld%\%%b" (
		if "%%a"=="1" echo Modified files:
		fc "%rootFolderOld%%folderOld%\%%b" "%rootFolderNew%%folderNew%\%%b" >nul || echo %%b >> "%outputMod%" && set /a count2+=1 && echo %%b
	)
)

:missFilesOld
rem Look for missing files in oldFolder
setlocal DisableDelayedExpansion
rem Use findstr /n "^" if exclusions cause problems
for /f "delims=: tokens=1*" %%a in ('dir /b /a-d /o:en "%rootFolderNew%%folderNew%\*" ^| findstr /v /i /n "%excluded%"') do (
	title fastcompare ver. %releaseDate% - Scanning %%b
	if "%%a"=="1" %EDE% & echo. & echo Files not present in !folderOld!: & %DDE%
	if not exist "%rootFolderOld%%folderOld%\%%b" (
		set /a count3+=1
		echo %%b >> "%outputOld%"
		echo %%b
	)
)

:missFilesNew
rem Look for missing files in newFolder
rem Use findstr /n "^" if exclusions cause problems
for /f "delims=: tokens=1*" %%a in ('dir /b /a-d /o:en "%rootFolderOld%%folderOld%\*" ^| findstr /v /i /n "%excluded%"') do (
	title fastcompare ver. %releaseDate% - Scanning %%b
	if "%%a"=="1" %EDE% & echo. & echo Files not present in !folderNew!%suffix%: & %DDE%
	if not exist "%rootFolderNew%%folderNew%\%%b" (
		set /a count4+=1
		echo %%b >> "%outputNew%"
		echo %%b
	)
)
echo.

rem Results
echo Results:
setlocal EnableDelayedExpansion
if !count2! gtr 0 echo Modified files: !count2!
if !count3! gtr 0 echo Files not present in !folderOld!: !count3!
if !count4! gtr 0 echo Files not present in !folderNew!%suffix%: !count4!
if "!count2!!count3!!count4!"=="" echo !folderOld! and !folderNew!%suffix% are identical^^!

title fastcompare ver. %releaseDate% - Comparison finished^^!
popd & pause >nul & exit

:SUB_folderBrowser
setlocal DisableDelayedExpansion
if "%type%"=="rootOld" (
	if %count% lss 1 set /p openBrowser=Open Folder Browser? [Y/N]: "
	if %count% lss 1 (
		if not "%openBrowser%"=="y" exit
	)
)
if "%type%"=="rootNew" (
	if %count1% lss 1 set /p openBrowser=Open Folder Browser? [Y/N]: "
	if %count1% lss 1 (
		if not "%openBrowser%"=="y" exit
	)
)
set count=0 & set count1=0 & echo Opening Folder Browser... & echo.
echo Select the root system folder, not the system itself!

rem PowerShell-Subroutine to open a Folder Browser
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please choose a folder.',0,0).self.path""
for /f "usebackq delims=" %%i in (`powershell %psCommand%`) do set "newRoot=%%i"

if "%type%"=="rootOld" set "rootFolderOld=%newRoot%\" & set "rootFolderNew=%newRoot%\"
if "%type%"=="rootNew" set "rootFolderNew=%newRoot%\"

rem Change working directory
if "%type%"=="rootOld" cls & pushd %rootFolderOld% & goto listFoldersOld
if "%type%"=="rootNew" cls & pushd %rootFolderNew% & %EDE% & echo Selected old folder: %rootFolderOld%!folderOld! & echo.
echo Current directory: %rootFolderNew% & echo. & goto listFoldersNew
