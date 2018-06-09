@echo off
setlocal EnableDelayedExpansion

:: This script assumes that you have adb in the same location, and it
:: also assumes that you are neither currently in a battle nor have a
:: shop item open.

:: The team to farm with
set "use_team_number=1"

:: Number of special maps available and map to farm on (use 1 for the 1st one, 2 for the second, etc.)
set "num_special_maps=7"
set "farm_on_map=1"

::::::::::::::::::::::::::::::::::::::::::::
:: DO NOT MODIFY ANYTHING BELOW THIS LINE ::
::::::::::::::::::::::::::::::::::::::::::::

:: Function output container.
set "foutput="

:: Low row of buttons on the FEH gui as a percentage * 1000
:: Note that these values are for 9:16 phones.
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

mode 50, 3
echo.
echo   INITIALIZING...

:: Initializes the daemon if it's not running already
adb devices > nul

:: Ensure that adb is in the same directory as this cmd file.
if [%errorlevel%]==[0] (
	rem Ensures that bc is in the right directory
	bc -v > nul

	if not [%errorlevel%]==[0] (
		color 0C
		mode 28, 9
		cls
		echo.
		echo  ERROR: BC IS NOT FOUND!
		echo.
		echo  Add bc.exe and dc.exe from
		echo  the download page and try
		echo  again.

		explorer "https://embedeo.org/ws/command_line/bc_dc_calculator_windows/bc-1.07.1-win32-embedeo-02.zip"

		echo.
		echo  Press any key to exit...
		pause > nul
		goto:eof
	) else (
		goto getscreensize
	)
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

:: Obtains the screen size of the connected device in pixels
:getscreensize
	for /f "tokens=3 delims= " %%A in ('adb shell wm size') do set "phone_dim=%%A"
	for /f "tokens=1,2 delims=x" %%A in ("%phone_dim%") do (
		rem https://superuser.com/questions/404338/check-for-only-numerical-input-in-batch-file
		set "width=%%A"
		set "height=%%B"

		set /a "width_num=width+0"
		set /a "height_num=height+0"

		if not [!width!]==[!width_num!] (
			color 0C
			mode 40, 26
			cls
			echo.
			echo  ERROR: INVALID WIDTH DIMENSION!
			echo.
			echo  The adb connection to your phone
			echo  found a bad value when attempting
			echo  to get its width in pixels.
			echo.

			adb devices

			echo.
			echo  If the text above appears to have
			echo  an error of some sort, check your
			echo  connection or search the error
			echo  on Google for a fix and try again.
			echo.
			echo  If you keep seeing this error, contact
			echo  the developer and follow any ins-
			echo  trunctions given to attempt to fix
			echo  the issue.
			echo.
			echo  Press any key to exit...
			pause > nul
			exit
		)

		if not [!height!]==[!height_num!] (
			color 0C
			mode 37, 16
			cls
			echo.
			echo  ERROR: INVALID HEIGHT DIMENSION!
			echo.
			echo  The adb connection to your phone
			echo  found a bad value when attempting
			echo  to get its height in pixels.
			echo.
			echo  Make sure that your phone is pro-
			echo  perly connected and try again. If
			echo  you keep seeing this error, contact
			echo  the developer and follow any ins-
			echo  trunctions given to attempt to fix
			echo  the issue.
			echo.
			echo  Press any key to exit...
			pause > nul
			exit
		)

		goto checkunlocked
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
	:: Check if the app is already running in the foreground to avoid the initialization subroutine.
	adb shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'" | find "com.nintendo.zaba" > nul
	if [%errorlevel%]==[0] (
		goto init
	)

	:: Determine whether or not the app was simply running in the background.
	set "feh_in_bg="
	adb shell ps | find "com.nintendo.zaba" > nul
	if [%errorlevel%]==[0] (
		set "feh_in_bg=true"
	)

	:: Attempt to start the app and make it focused if not already.
	adb shell monkey -p com.nintendo.zaba 1 > nul

	:: There is nothing else to do if the app was simply switched from the bg to the fg (assuming FEH is not on title screen)
	if defined feh_in_bg goto init

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
		call :getpixelvalue 500 !width!
		set "x=!foutput!"
		call :getpixelvalue 500 !height!
		set "y=!foutput!"
		adb shell input tap !x! !y! > nul

		timeout /t 15 /nobreak

		:: Calculate the exit button for the notifications and tap it a few times
		call :getpixelvalue %app_init_x% !width!
		set "x=!foutput!"
		call :getpixelvalue %app_init_y% !height!
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
	mode 44, 3
	cls
	echo.
	echo  FARMING HERO MERIT USING GIVEN SETTINGS...
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
	set "screenb=%~1"
	if [%~1]==[] (
		set "screenb=%homeb%"
	)
	call :getpixelvalue !screenb! !width!
	set "x=!foutput!"

	call :getpixelvalue %bottom_row% !height!
	set "y=!foutput!"

	:: Send the command over adb
	adb shell input tap !x! !y! > nul
	timeout /t 1 /nobreak > nul
	goto:eof

:: Specialty subroutine for the :battlescreen subroutine to enter the special maps
:specialmaps
	:: Calculate the right column pixel value
	call :getpixelvalue %right_battle_column% !width!
	set "x=!foutput!"

	:: Calculate the pixel value for the special maps battle option
	call :getpixelvalue %specialmapsb% !height!
	set "y=!foutput!"

	:: Go to the special maps screen
	adb shell input tap !x! !y! > nul
	timeout /t 1 /nobreak > nul
	goto:eof

:: Converts the custom percentage values defined above
:: to pixel values that can be used by adb
:getpixelvalue
	set "coord=%~1"
	if [%~1]==[] (
		set "coord=0"
	)

	set "dim=%~2"
	if [%~2]==[] (
		set "dim=0"
	)

	set /a "foutput=coord*dim"
	set /a "foutput/=1000"
	
	goto:eof



endlocal
