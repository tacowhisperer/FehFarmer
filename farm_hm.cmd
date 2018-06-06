@echo off
setlocal EnableDelayedExpansion

:: This script assumes that you have adb in the same location, and it
:: also assumes that you are neither currently in a battle nor have a
:: shop item open.

:: Input device width and height in pixels
set /a "width=1080"
set /a "height=1920"

:: The team to farm with
set "use_team_number=1"

:: Number of special maps available and map to farm on (use 1 for the 1st one, 2 for the second, etc.)
set "num_special_maps=7"
set "farm_on_map=1"

:: DO NOT MODIFY ANYTHING BELOW THIS LINE ::
mode 50, 3
echo.

:: Except this line if you're so inclined...
echo   FARMING HERO MERIT...

:: Function output container.
set "foutput="

:: Low row of buttons on the FEH gui as a percentage * 100
set "bottom_row=964"
set "homeb=65"
set "battleb=250"
set "alliesb=407"
set "summonb=588"
set "shopb=750"
set "miscb=926"

:: Battle screen options
set "left_battle_column=234"
set "right_battle_column=750"
set "blessedg=250"
set "specialmaps=250"
set "storymaps=500"
set "arenaduels=500"
set "trainingt=750"
set "events=750"

adb devices > nul

::loop
call :battlescreen
call :enterghb
goto:eof

:battlescreen
	:: Calculate the battle button pixel value
	call :getpixelvalue %battleb% %width%
	set "x=!foutput!"

	:: Calculate the bottom row pixel value
	call :getpixelvalue %bottom_row% %height%
	set "y=!foutput!"

	:: Go to the battle screen
	adb shell input tap !x! !y!
	timeout /t 1 > nul
	goto:eof

:enterghb
	:: Calculate the right column pixel value
	call :getpixelvalue %right_battle_column% %width%
	set "x=!foutput!"

	:: Calculate the pixel value for the special maps battle option
	call :getpixelvalue %specialmaps% %height%
	set "y=!foutput!"

	:: Go to the special maps screen
	adb shell input tap !x! !y!
	timeout /t 1 > nul
	goto:eof

:: Converts percentage values to pixel values that can be used by adb
:getpixelvalue
	set "coord=%1"
	if [%1]==[] (
		set "coord=0"
	)

	set "dim=%2"
	if [%2]==[] (
		set "dim=0"
	)

	set /a "foutput=coord*dim"
	set /a "foutput/=1000"
	
	goto:eof
