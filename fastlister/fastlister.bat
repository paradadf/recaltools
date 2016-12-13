@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=14.12.2016
title fastlister ver. !releaseDate!

rem List of excluded extensions
set excluded=.xml .txt

rem Show folder names in current directory
echo Available folders for listing:
for /d %%a in (*) do (
set /a count+=1
set mapArray[!count!]=%%a
echo !count!: %%a
)
if not exist !mapArray[1]! cls & echo No folders found on current directory^^! & pause >nul & goto:eof
echo.

:whichFolder
rem Select folder(s) to be listed
echo The content of which folder(s) do you want to list? All?
set /p "whichFolder=#: "
if "%whichFolder%"=="" echo Incorrect input^^! & echo. & goto whichFolder
if /i not "%whichFolder%"=="all" goto listFolders
	set "folders="
	for /f "delims=" %%f in ('dir /b /a:d') do set folders=!folders! "%%f"
	goto outputFolder

:listFolders
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
if not exist %destFolder% md %destFolder%

:listContent
echo.
title fastlister ver. !releaseDate! - Creating lists...
for /d %%f in (%folders%) do (
	cd %%~f && echo Scanning %%~f...
	dir /b /a:-d /o:en 2>nul | findstr /v /i "%excluded%" >> ..\%destFolder%\%%~f.txt
	cd ..
)

rem Detect and delete empty files on output folder
echo.
for %%f in (%destFolder%\*) do (
	if %%~zf equ 0 echo %%~nf has no elements to list. & del "%%f"
)

rem Delete output folder if empty
echo.
dir /a-d "%destFolder%\*" >nul 2>nul && (echo Find the lists inside bestLists folder^^!) || (rd "%destFolder%" & echo No lists created^^!)

title fastlister ver. !releaseDate! - Scanning directories finished^^!

pause >nul