@echo off
color 3f
set releaseDate=11.01.2017
title fastscraper ver. %releaseDate%

rem Set ScreenScraper credentials
set username=""
set password=""

rem Flags - Static parameters
	rem If true, add roms that are not found as an empty gamelist entry.
		set addNotFound=-add_not_found=false

	rem Comma separated order to prefer images, s=snapshot, b=boxart, f=fanart, a=banner, l=logo, 3b=3D boxart. (default "b")
		set consoleImg=-console_img="b,s"

	rem Comma seperated order to prefer console sources, ss=screenscraper, ovgdb=OpenVGDB, gdb=theGamesDB (default "gdb")
		set consoleSrc=-console_src="ss"
		
	rem If false, don't download any images, instead see if the expected file is stored locally already. (default true)
		set downloadImg=-download_images=true

	rem Comma separated list of extensions to also include in the scraper.
		set extraExt=-extra_ext=".scummvm,.ipf,.mx1,.mx2,.exe,.ws,.wsc,.wad"

	rem jpg or png, the format to write the images. (default "jpg")
		set imgFormat=-img_format="jpg"

	rem The path to use for images in gamelist.xml. (default "images")
		set imagePath=-image_path="./downloaded_images"

	rem  The suffix added after rom name when creating image files. (default "-image")
		set imageSuffix=-image_suffix="-image"
		
	rem The order to choose for language if there is more than one for a value. (en, fr, es, de, pt) (default "en")
		set langSS=-lang="en,es,pt,de,fr"

	rem Comma separated order to prefer images, s=snap, t=title, m=marquee, c=cabniet. (default "t,m,s,c")
	rem Not documented yet: b=boxart, 3b=3D boxart (https://github.com/sselph/scraper/issues/126)
		set mameImg=-mame_img="b,s,m,t"
		
	rem Comma seperated order to prefer mame sources, ss=screenscraper, mamedb=mamedb-mirror, gdb=theGamesDB-neogeo (default "mamedb,gdb")
		set mameSrc=-mame_src="ss"

	rem The max height of images. Larger images will be resized.
		set maxHeight=-max_height=0

	rem The max width of images. Larger images will be resized. (default 400)
		set maxWidth=-max_width=400

	rem Don't add thumbnails to the gamelist.
		set noThumb=-no_thumb=true

	rem Information will be attempted to be downloaded again but won't remove roms that are not scraped.
		set refreshXML=-refresh=false

	rem The order to choose for region if there is more than one for a value. (us, eu, jp, fr, xx) (default "us,eu,jp,fr,xx")
		set regionSS=-region="us,eu,jp,fr,xx"

	rem The `username` for registered ScreenScraper users.
		set username=-ss_user=%username%

	rem The `password` for registered ScreenScraper users.
		set password=-ss_password=%password%
	
	rem If true, use the filename minus the extension as the game title in xml.
		set useFilename=-use_filename=false

    	rem Use the name in the No-Intro DB instead of the one in the GDB. (default true)
		set useNoIntroName=-use_nointro_name=true

	rem Use N worker threads to process roms. (default 1)
		set workersN=-workers=4

rem Set default roms directory to launch directory
set "romsDir=%cd%"	

:scraperEXE
rem Check if scraper.exe is on root folder
if exist scraper.exe goto scraperVersion
echo scraper.exe missing
set /P "download=Do you want to open the URL to download it? [Y/N]: "
if /I "%download%"=="y" start https://github.com/sselph/scraper/releases & goto:eof
if /I "%download%"=="n" goto:eof
echo Incorrect input! & goto scraperEXE

:scraperVersion
rem Show scraper version
echo scraper.exe's version found: & scraper.exe -version		
	
:systemSelection
rem Select the system to scrape (type "all" to scrape all folders)
setlocal EnableDelayedExpansion
echo Which system(s) do you want to scrape? All? Type "cd" to open the folder browser.
set /P "system="
if "%system%"=="cd" goto SUB_folderBrowser
if "%system%"=="" echo Incorrect input^^! & goto systemSelection
if /I not "%system%"=="all" goto modeSelection
	set "system="
	for /F "delims=" %%f in ('dir /B /A:D "%romsDir%"') do set system=!system! %%f

:modeSelection
rem Choose to append an existing (y) or create a new gamelist (n)
if "%refreshXML%"=="-refresh=true" goto fullMode
set /P "appendXML=Would you like to append existing gamelists? [Y/N]: "
if /I "%appendXML%"=="y" goto appendMode
if /I "%appendXML%"=="n" goto fullMode
echo Incorrect input & goto modeSelection

	:appendMode
	set appendMode=-append & goto startTime

	:fullMode
	set "appendMode="

:startTime
rem Save start time
set startTime=%time%

rem ******************** MAIN CODE SECTION

for %%i in (%system%) do (

rem Check if mame device is selected and set corresponding flags
	set "arcade="
	echo %%i | findstr /LIC:"arcade" >nul && set arcade=-mame %mameImg% %mameSrc%
	echo %%i | findstr /LIC:"fba" >nul && set arcade=-mame %mameImg% %mameSrc%
	echo %%i | findstr /LIC:"mame" >nul && set arcade=-mame %mameImg% %mameSrc%
	echo %%i | findstr /LIC:"neogeo" >nul && set arcade=-mame %mameImg% %mameSrc%

rem If mame device, consoleImg not used
	if not "!arcade!"=="" set "consoleImg="

	echo.
	title fastscraper ver. %releaseDate% - Scraping %%i...

rem Scraping roms
	echo Scraping %%i in progress. Please wait...
	echo.
scraper.exe %appendMode% !arcade! -rom_dir="!romsDir!\%%i" %imagePath% -image_dir="!romsDir!\%%i\%imagePath:~15,-1%" %imageSuffix% -output_file="!romsDir!\%%i\gamelist.xml" -missing="!romsDir!\%%i\_%%i_missing.txt" %addNotFound% !consoleImg! %consoleSrc% %downloadImg% %extraExt% %imgFormat% %langSS% %maxHeight% %maxWidth% %noThumb% %refreshXML% %regionSS% %username% %password% %useFilename% %useNoIntroName% %workersN%
	echo.
	
)

rem ******************** END MAIN CODE SECTION

title fastscraper ver. %releaseDate% - Scraping has finished^^!

rem Save finish time
set endTime=%time%

rem Change formatting for the start and end times
    for /F "tokens=1-4 delims=:.," %%a in ("%startTime%") do (
       set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )

    for /F "tokens=1-4 delims=:.," %%a in ("%endTime%") do (
       set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )

    rem Calculate the duration by subtracting values
    set /A elapsed=end-start
	
	rem Correct if the measurement was in between days (8640000 centisec/day)
	if %end% lss %start% set /A elapsed=end-start+8640000

    rem Format the results for output
    set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
    if %hh% lss 10 set hh=0%hh%
    if %mm% lss 10 set mm=0%mm%
    if %ss% lss 10 set ss=0%ss%
    if %cc% lss 10 set cc=0%cc%

    set DURATION=%hh%:%mm%:%ss%,%cc%

    echo Start    : %startTime%
    echo Finish   : %endTime%
    echo          ---------------
    echo Duration : %DURATION%
	
pause >nul & exit

:SUB_folderBrowser
setlocal DisableDelayedExpansion
echo.
echo Opening Folder Browser...

rem PowerShell-Subroutine to open a Folder Browser
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please choose the roms folder.',0,0).self.path""
for /F "usebackq delims=" %%i in (`powershell %psCommand%`) do set "newRoot=%%i"

set "romsDir=%newRoot%"
cls & echo Selected roms folder: %romsDir%
rem Check if scraping from network drive and show warning about stopping ES
if not x%romsDir:\\=%==x%romsDir% echo Don't forget to stop EmulationStation before scraping!
echo. & goto systemSelection
