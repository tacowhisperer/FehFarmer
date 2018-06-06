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

:: Low row of buttons on the FEH gui as a percentage * 1000
set "bottom_row=960"
set "homeb=78"
set "battleb=245"
set "alliesb=413"
set "summonb=581"
set "shopb=748"
set "miscb=916"

:: Battle screen options
set "left_battle_column=234"
set "right_battle_column=750"
set "blessedgb=250"
set "specialmapsb=250"
set "storymapsb=500"
set "arenaduelsb=500"
set "trainingtb=750"
set "eventsb=750"

adb devices > nul

::loop
::call :alliesscreen
::call :editteams
call :battlescreen
call :specialmaps
goto:eof

:alliesscreen
	call :gotoscreen %alliesb%
	goto:eof

:battlescreen
	call :gotoscreen %battleb%
	goto:eof

:: Helper subroutine for selecting a bottom row button on the FEH gui.
:gotoscreen
	:: Get the selected button's x-coordinate
	set "screenb=%1"
	if [%1]==[] (
		set "screenb=%homeb%"
	)
	call :getpixelvalue !screenb! %width%
	set "x=!foutput!"

	call :getpixelvalue %bottom_row% %height%
	set "y=!foutput!"

	:: Send the command over adb
	adb shell input tap !x! !y!
	timeout /t 1 > nul
	goto:eof

:: Specialty subroutine for the :battlescreen subroutine to enter the special maps
:specialmaps
	:: Calculate the right column pixel value
	call :getpixelvalue %right_battle_column% %width%
	set "x=!foutput!"

	:: Calculate the pixel value for the special maps battle option
	call :getpixelvalue %specialmapsb% %height%
	set "y=!foutput!"

	:: Go to the special maps screen
	adb shell input tap !x! !y!
	timeout /t 1 > nul
	goto:eof

:: Converts the custom percentage values defined above
:: to pixel values that can be used by adb
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
