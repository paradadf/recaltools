@echo off
setlocal EnableDelayedExpansion
color 3f
set releaseDate=06.11.2016
title fast7ztoZip ver. !releaseDate!

:7zEXE
rem Check if 7z.exe is installed on the computer
set pf=!programfiles!
if exist !pf!\7-Zip\7z.exe goto reZip
if exist "!pf! (x86)\7-Zip\7z.exe" set "pf=!pf! (x86)" & goto reZip
echo 7-Zip missing
set /p "download=Do you want to open the URL to download it? [Y/N]: "
if /i "!download!"=="y" start http://www.7-zip.org/ & goto:eof
if /i "!download!"=="n" goto:eof
echo Incorrect input & goto 7zEXE

:reZip
title Converting .7z to .zip...
rem Convert .7z to .zip
for %%f in (*.7z) do ( 
	"!pf!\7-Zip\7z.exe" x -y -o"%%f_tmp" "%%f" *
	pushd %%f_tmp 
	"!pf!\7-Zip\7z.exe" a -y -r -t7z ..\"%%~nf".zip * 
	popd 
	rmdir /s /q "%%f_tmp" 
)

title fast7ztoZip ver. !releaseDate! - Conversion has finished
pause >nul