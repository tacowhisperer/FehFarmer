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
echo   INITIALIZING...

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

:: First tap location
set "app_init_x=916"
set "app_init_y=885"

:: Battle screen options
set "left_battle_column=234"
set "right_battle_column=750"
set "blessedgb=250"
set "specialmapsb=250"
set "storymapsb=500"
set "arenaduelsb=500"
set "trainingtb=750"
set "eventsb=750"

:: Special maps button heights as of v2.5.0
set "specialmapsb_offset=333"
set "specialmapsb_height=161"

:: Initializes the daemon if it's not running already
adb devices > nul

:: Ensure that adb is in the same directory as this cmd file.
if [%errorlevel%]==[0] (
	goto checkunlocked
) else (
	color 0C
	mode 34, 9
	cls
	echo.
	echo  ERROR: ADB IS NOT FOUND!
	echo.
	echo  Add adb.exe and the appropriate
	echo  accompanying .dll files from the
	echo  download page and try again.

	explorer "https://developer.android.com/studio/releases/platform-tools"

	echo.
	echo  Press any key to exit...
	pause > nul
	goto:eof
)

:: Ensure that the device is unlocked.
set "unlock_tries=0"
set "nfc_found="
:checkunlocked
	::Source
	::https://stackoverflow.com/questions/35275828/is-there-a-way-to-check-if-android-device-screen-is-locked-via-adb/35276479

	:: Check that the device is unlocked
	adb shell dumpsys nfc | find "mScreenState=" | find "UNLOCKED" > nul
	if [%errorlevel%]==[0] (
		goto ensurefehworks
	) else (
		if !unlock_tries! GEQ 5 (
			color 0E
			mode 37, 14
			cls
			echo.
			echo  WARNING: DEVICE MAY NOT HAVE NFC
			echo.
			echo  Due to a limitation with adb, a
			echo  device without nfc cannot guarantee
			echo  that it is on while the script is
			echo  executing.
			echo.
			echo  The script will continue to run
			echo  under the assumption that you will
			echo  keep an eye on its functionality.
			echo.
			echo  Press any key to continue...
			pause > nul
			goto ensurefehworks
		) else (
			color 0C
			mode 43, 8
			cls
			echo.
			echo  ERROR: DEVICE IS LOCKED!
			echo.
			echo  Make sure that the device is unlocked so
			echo  that the script may do its thing.
			echo.
			echo  When ready, press any key to try again...
			pause > nul
			cls
			echo.
			echo  Retrying...
			set /a "unlock_tries+=1"
			timeout /t 1 /nobreak > nul
			goto checkunlocked
		)
	)

	goto:eof

:: Ensure that Fire Emblem Heroes is working correctly.
:ensurefehworks
	:: Check if the app is already running to avoid the initialization subroutine.
	adb shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'" | find "com.nintendo.zaba" > nul
	if [%errorlevel%]==[0] (
		goto init
	)

	:: Attempt to start the app and make it focused if not already.
	adb shell monkey -p com.nintendo.zaba 1 | find "Events injected: 1" > nul

	color 07
	mode 50, 4
	cls
	echo.
	echo  Launching FEH...


	:: Give the app time to open and load before continuing. This time is overkill on any decent phone/internet.
	timeout /t 15 /nobreak

	:: Ensure that FEH is the focused app right now, and if not, it's not installed.
	adb shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'" | find "com.nintendo.zaba" > nul
	if [%errorlevel%]==[0] (
		cls
		echo.
		echo  Entering game...

		:: Calculate the center of the screen and tap it
		call :getpixelvalue 500 %width%
		set "x=!foutput!"
		call :getpixelvalue 500 %height%
		set "y=!foutput!"
		adb shell input tap !x! !y! > nul

		timeout /t 15 /nobreak

		:: Calculate the exit button for the notifications and tap it a few times
		call :getpixelvalue %app_init_x% %width%
		set "x=!foutput!"
		call :getpixelvalue %app_init_y% %height%
		set "y=!foutput!"

		for /L %%i in (1,1,5) DO (
			adb shell input tap !x! !y!
		)

		goto init
	) else (
		color 0C
		mode 44, 11
		cls
		echo.
		echo  ERROR: FE HEROES IS NOT INSTALLED!
		echo.
		echo  Make sure that it is properly installed,
		echo  the tutorial is finished, all rewards have
		echo  been claimed, and on the homepage. Then,
		echo  feel free to try again.
		echo.
		echo  If you keep seeing this message, there is
		echo  something wrong with adb and it must be
		echo  addressed.
		echo.
		echo  Press any key to exit...
		pause > nul
		exit
	)

	goto:eof

:init
	color 07
	mode 50, 3
	cls
	echo.
	echo   FARMING HERO MERIT USING GIVEN SETTINGS...
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
	timeout /t 1 /nobreak > nul
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
	timeout /t 1 /nobreak > nul
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

endlocal
