@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=07.11.2016
title fastscraper ver. !releaseDate!

:scraperEXE
rem Check if scraper.exe is on root folder
if exist scraper.exe goto scraperVersion
echo scraper.exe missing
set /p "download=Do you want to open the URL to download it? [Y/N]: "
if /i "!download!"=="y" start https://github.com/sselph/scraper/releases & goto:eof
if /i "!download!"=="n" goto:eof
echo Incorrect input & goto scraperEXE

:scraperVersion
rem Show scraper version
echo scraper.exe's version found: & scraper.exe -version

rem Flags - Static parameters
	rem If true, add roms that are not found as an empty gamelist entry.
		set addNotFound=-add_not_found=false

	rem Comma separated order to prefer images, s=snapshot, b=boxart, f=fanart, a=banner, l=logo, 3b=3D boxart. (default "b")
		set consoleIMG=-console_img="b,s"
		
	rem Comma separated list of extensions to also include in the scraper.
		set extraExt=-extra_ext=".scummvm,.ipf,.mx1,.mx2,.exe,.ws,.wsc,.wad"
	
	rem jpg or png, the format to write the images. (default "jpg")
		set imgFormat=-img_format="jpg"
		
	rem The order to choose for language if there is more than one for a value. (en, fr, es, de, pt) (default "en")
		set langSS=-lang="en,es,pt,de,fr"
	
	rem The path to use for images in gamelist.xml. (default "images")
		set imagePath=-image_path="./downloaded_images"
	
	rem  The suffix added after rom name when creating image files. (default "-image")
		set imageSuffix=-image_suffix="-image"
		
	rem The max width of images. Larger images will be resized. (default 400)
		set maxWidth=-max_width=400

	rem Don't add thumbnails to the gamelist.
		set noThumb=-no_thumb=true
	
	rem Information will be attempted to be downloaded again but won't remove roms that are not scraped.
		set refreshXML=-refresh=false
	
	rem The order to choose for region if there is more than one for a value. (us, eu, jp, fr, xx) (default "us,eu,jp,fr,xx")
		set regionSS=-region="us,eu,jp,fr,xx"
    
	rem Use the hash.csv and theGamesDB metadata. (default true)
		set useGDB=-use_gdb=false
	
    rem Use the name in the No-Intro DB instead of the one in the GDB. (default true)
		set useNoIntroName=-use_nointro_name=true
	
	rem Use the OpenVGDB if the hash isn't in hash.csv.
		set useOVGDB=-use_ovgdb=false
	
	rem Use the ScreenScraper.fr as a datasource.
		set useSS=-use_ss=true
	
	rem Use N worker threads to process roms. (default 1)
		set workersN=-workers=4

:systemSelection
rem Select the system to scrape (type "all" to scrape all folders)
set /p "system=Which system(s) do you want to scrape? All? "
if "%system%"=="" echo Incorrect input & goto systemSelection
if /i not "%system%"=="all" goto modeSelection
	set "system="
	for /f "delims=" %%f in ('dir /b /a:d') do set system=!system! %%f

:modeSelection
rem Choose to append an existing (y) or create a new gamelist (n)
if "!refreshXML!"=="-refresh=true" goto fullMode
set /p "appendXML=Would you like to append existing gamelists? [Y/N]: "
if /i "!appendXML!"=="y" goto appendMode
if /i "!appendXML!"=="n" goto fullMode
echo Incorrect input & goto modeSelection

	:appendMode
	set appendMode=-append & goto neogeoMode

	:fullMode
	set "appendMode=" & goto neogeoMode

:neogeoMode
rem Select source for NeoGeo: mameDB.com (mame-mode) and theGamesDB.net (non-mame mode)
echo %system%|findstr /lic:"neogeo" >nul
if "%errorlevel%"=="0" (
set /p "nonmameMode=Scrape NeoGeo in non-mame mode (use theGamesDB)? [Y/N]: "
if /i "!nonmameMode!"=="y" goto startTime
if /i "!nonmameMode!"=="n" goto startTime 
echo Incorrect input & goto neogeoMode
)

:startTime
rem Save start time
set startTime=%time%

rem ******************** MAIN CODE SECTION

for %%i in (%system%) do (

rem Check if mame device is selected
rem Comma separated order to prefer images, s=snap, t=title, m=marquee, c=cabinet. (default "t,m,s,c")
set "arcade="
echo %%i|findstr /lic:"fba" >nul && set arcade=-mame -mame_img="s,m,t"
echo %%i|findstr /lic:"fba_libretro" >nul && set arcade=-mame -mame_img="s,m,t"
echo %%i|findstr /lic:"mame" >nul && set arcade=-mame -mame_img="s,m,t"
echo %%i|findstr /lic:"neogeo" >nul && set arcade=-mame -mame_img="s,m,t"

rem Change flags if NeoGeo in non-mame mode was selected
rem Comma separated order to prefer images, s=snapshot, b=boxart, f=fanart, a=banner, l=logo, 3b=3D boxart. (default "b")
echo %%i|findstr /lic:"neogeo" >nul && if "!nonmameMode!"=="y" set arcade=-console_img="b,s"

if "!arcade!"=="" (
set imageMode=!consoleIMG!
) else (
set "imageMode="
)

echo.
title Scraping %%i...

rem Scraping roms
echo Scraping %%i in progress. Please wait...
echo.
scraper.exe !appendMode! !arcade! -rom_dir="%%i" !imagePath! -image_dir="%%i\!imagePath:~15,-1!" !imageSuffix! -output_file="%%i\gamelist.xml" -missing="%%i\_%%i_missing.txt" !addNotFound! !imageMode! !extraExt! !imgFormat! !langSS! !noThumb! !refreshXML! !regionSS! !maxWidth! !useGDB! !useNoIntroName! !useOVGDB! !useSS! !workersN!
echo.

)

rem ******************** END MAIN CODE SECTION

title fastscraper ver. !releaseDate! - Scraping has finished

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
	
pause >nul
