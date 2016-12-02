@echo off
color 3f
set releaseDate=18.11.2016
title fastsorter ver. %releaseDate%

:whichSystem
rem Select system folder
echo Which system do you want to sort?
echo 1: fba_libretro & echo.2: mame
set /p "system=#: "
if "%system%"=="1" set "system=fba_libretro" & echo. & goto whichFolder
if "%system%"=="2" set "system=mame" & echo. & goto whichFolder
echo Incorrect input & echo. & goto whichSystem

:whichFolder
rem Select the folder where the roms will be copied
echo Where do you want to copy your roms?
echo 1: Complete DAT & echo.2: Parents only & echo.3: Parents only (without NeoGeo) & echo.4: NeoGeo only (including NeoGeo Clones) & echo.5: NeoGeo Parents only
set /p "folder=#: "
if "%folder%"=="1" set "destFolder=Complete DAT" & echo. & goto whichGamelist
if "%folder%"=="2" set "destFolder=Parents only" & echo. & goto whichGamelist
if "%folder%"=="3" set "destFolder=Parents only (without NeoGeo)" & echo. & goto whichGamelist
if "%folder%"=="4" set "destFolder=NeoGeo only (including NeoGeo Clones)" & echo. & goto whichGamelist
if "%folder%"=="5" set "destFolder=NeoGeo Parents only" & echo. & goto whichGamelist
echo Incorrect input & echo. & goto whichFolder

:whichGamelist
rem Check if a corresponding *.txt exists and use it instead of fastsorter.txt
if exist "%destFolder%.txt" (set "gamelist=%destFolder%") else set "gamelist=fastsorter"
if "%gamelist%"=="fastsorter" echo If '%destFolder%.txt' exists, it will be used as source, otherwise fastsorter.txt
echo.

:createFolder
rem Create the selected folder
md ".\%system%\%destFolder%"

rem Look inside the gamelist and copy the roms to the destination folder
if not exist "%gamelist%.txt" echo The file %gamelist%.txt is missing! & echo. & pause & goto:eof
title fastsorter ver. %releaseDate% - Sorting roms in progress...
for /f "delims=" %%a in ('type "%gamelist%.txt"') do if exist ".\%system%\%%a" (copy ".\%system%\%%a" ".\%system%\%destFolder%\%%~nxa") else echo %%a missing
title fastsorter ver. %releaseDate% - Sorting roms finished!

echo.
pause
