@echo off
title FEH Farmer
setlocal EnableDelayedExpansion

:: The team to farm with
set "use_team_number=1"

:: Number of special maps available and map to farm on (use 1 for the 1st one, 2 for the second, etc.)
set "num_special_maps=7"
set "farm_on_map=1"

::::::::::::::::::::::::::::::::::::::::::::
:: DO NOT MODIFY ANYTHING BELOW THIS LINE ::
::::::::::::::::::::::::::::::::::::::::::::

:: Ensures that bc is in the right directory. The program may not continue if it cannot do math, duh...
bc -v > nul

if not "%errorlevel%" == "0" (
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
)

:: adb screen rotation values
set "portrait_orientation=0"
set "landscape_orientation=1"
set "portrait_reversed_orientation=2"
set "landscape_reversed_orientation=3"

:: Function output container.
set "foutput=null"

:: Fire Emblem...*inhales*... HEROES!!!
set "welcome_x_fui=0.5"
set "welcome_y_fui=0.75"

:: Banners available pop-up coordinates to close the screen
set "banner_x_fui=0.5"
for /f "tokens=*" %%i in ('"echo 1073 / 1280 | bc -l"') do set "banner_y_fui=%%i"

:: Notifications from Nintendo using the phone user interface (pui)
for /f "tokens=*" %%i in ('"echo 985 / 1080 | bc -l"') do set "notifications_x_pui=%%i"

:: Celebration bonuses (big golden screens with the bread of every day)
set "celebration_bonus_x_fui=0.5"
for /f "tokens=*" %%i in ('"echo 1002 / 1280 | bc -l"') do set "celebration_bonus_y_fui=%%i"

:: Daily log-in bonus popup (usually dueling swords or feathers)
set "daily_login_bonus_x_fui=0.5"
for /f "tokens=*" %%i in ('"echo 807.5 / 1280 | bc -l"') do set "daily_login_bonus_y_fui=%%i"

:: Bottom row of buttons on the main FEH user interface (fui).
:: These are fractional values based on the FUI display ratio (37:64)
for /f "tokens=*" %%i in ('"echo 1230 / 1280 | bc -l"') do set "bottom_row_fui=%%i"
for /f "tokens=*" %%i in ('"echo 66.00 / 740 | bc -l"') do set "home_fui=%%i"
for /f "tokens=*" %%i in ('"echo 187.5 / 740 | bc -l"') do set "battle_fui=%%i"
for /f "tokens=*" %%i in ('"echo 308.5 / 740 | bc -l"') do set "allies_fui=%%i"
for /f "tokens=*" %%i in ('"echo 430.0 / 740 | bc -l"') do set "summon_fui=%%i"
for /f "tokens=*" %%i in ('"echo 551.0 / 740 | bc -l"') do set "shop_fui=%%i"
for /f "tokens=*" %%i in ('"echo 672.5 / 740 | bc -l"') do set "misc_fui=%%i"

:: First tap location
rem set "app_init_x=916"
rem set "app_init_y=885"

:: Battle screen options
for /f "tokens=*" %%i in ('"echo 188 / 740 | bc -l"') do set "left_battle_column_fui=%%i"
for /f "tokens=*" %%i in ('"echo 542 / 740 | bc -l"') do set "right_battle_column_fui=%%i"
set "blessedgb_fui=0.25"
set "specialmapsb_fui=0.25"
set "storymapsb_fui=0.5"
set "arenaduelsb_fui=0.5"
set "trainingtb_fui=0.75"
set "eventsb_fui=0.75"

:: Special maps button heights as of v2.5.0
set "specialmapsb_offset=333"
set "specialmapsb_height=161"

:: adb accelerometer values
set "stay_in_current_rotation=0"
set "rotate_screen_content=1"

mode 50, 3
echo.
echo   INITIALIZING...

:: Prevent a pop-up and unwanted text from showing up to the terminal
start cmd /c "adb devices" /b

:: Initializes the daemon if it's not running already
adb devices > nul

:: Ensure that adb is in the same directory as this cmd file.
if "%errorlevel%" == "0" (
	rem First set the screen orientation to be portrait
	rem Source: https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
	adb shell settings put system accelerometer_rotation %stay_in_current_rotation% > nul
	adb shell settings put system user_rotation %portrait_orientation% > nul

	goto getscreensize
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
	:: First we get the screen size and navigation bar dimensions
	for /f "tokens=*" %%i in ('"adb shell dumpsys window displays | findstr /R /C:cur=.*app="') do set "phone_info=%%i"

	:: Attempt to obtain the screen size information using the other adb method, but without the navbar size.
	if not defined phone_info (
		for /f "tokens=3 delims= " %%A in ('adb shell wm size') do set "phone_dim=%%A"
		for /f "tokens=1,2 delims=x" %%A in ("!phone_dim!") do (
			rem https://superuser.com/questions/404338/check-for-only-numerical-input-in-batch-file
			set "width=%%A"
			set "height=%%B"
			set "navheight=0"

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
				echo  tructions given to attempt to fix
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
				echo  tructions given to attempt to fix
				echo  the issue.
				echo.
				echo  Press any key to exit...
				pause > nul
				exit
			)

			goto checkunlocked
		)
	)

	:: Separate the information by spaces and get the relevant bits of information
	:: Format: init=####x#### ####dpi cur=####x#### app=####x#### rng=####x####-####x####
	for /f "tokens=1,5" %%i in ("!phone_info!") do (
		set "phone_dim_raw=%%i"
		set "phone_navbar_raw=%%j"

		rem Handle the case where the phone's dimensions are not correctly obtained
		if not defined phone_dim_raw (
			color 0C
			mode 39, 15
			cls
			echo.
			echo  ERROR: PARSE FAILURE^^!
			echo.
			echo  The output format for the command
			echo.
			echo  'adb shell dumpsys window displays'
			echo.
			echo  was not the expected format for the
			echo  screen dimensions. Check that the
			echo  connection to the phone was not
			echo  broken and that adb was still working
			echo  and try again.
			echo.
			echo  Press any key to exit...
			pause > nul
			exit
		)

		rem Handle the case where the phone's navbar dimensions are not correctly obtained
		if not defined phone_navbar_raw (
			color 0C
			mode 39, 15
			cls
			echo.
			echo  ERROR: PARSE FAILURE^^!
			echo.
			echo  The output format for the command
			echo.
			echo  'adb shell dumpsys window displays'
			echo.
			echo  was not the expected format for the
			echo  screen navbar. Check that the
			echo  connection to the phone was not
			echo  broken and that adb was still working
			echo  and try again.
			echo.
			echo  Press any key to exit...
			pause > nul
			exit
		)

		rem Process the phone's screen dimensions
		for /f "tokens=2 delims==" %%i in ("!phone_dim_raw!") do (
			set "phone_dim=%%i"

			rem Handle the case where the phone's dimension values are not = delimited
			if not defined phone_dim (
				color 0C
				mode 33, 13
				cls
				echo.
				echo  ERROR: FATAL PARSE FAILURE^^!
				echo.
				echo  The output format for the phone
				echo  screen dimensions in pixels is
				echo  not stored as a key=value pair.
				echo.
				echo  Your version of Android may not
				echo  be compatible with the version
				echo  of adb installed.
				echo.
				echo  Press any key to exit...
				pause > nul
				exit
			)

			rem Split the width and the height values and ensure that they are numerical
			for /f "tokens=1,2 delims=x" %%a in ("!phone_dim!") do (
				set "width=%%a"
				set "height=%%b"

				call :isnumerical !width!
				if "!foutput!"=="false" (
					color 0C
					mode 40, 13
					cls
					echo.
					echo  ERROR: NON-NUMERICAL VALUE OBTAINED
					echo.
					echo  The script encountered a non-numerical
					echo  value while trying to get the device 
					echo  width in pixels.
					echo.
					echo  Your Android version might not be com-
					echo  patible with the currently installed
					echo  version of adb.
					echo.
					echo  Press any key to exit...
					pause > nul
					exit
				)

				call :isnumerical !height!
				if "!foutput!"=="false" (
					color 0C
					mode 40, 13
					cls
					echo.
					echo  ERROR: NON-NUMERICAL VALUE OBTAINED
					echo.
					echo  The script encountered a non-numerical
					echo  value while trying to get the device 
					echo  height in pixels.
					echo.
					echo  Your Android version might not be com-
					echo  patible with the currently installed
					echo  version of adb.
					echo.
					echo  Press any key to exit...
					pause > nul
					exit
				)
			)
		)

		rem Process the phone's screen navbar dimensions
		for /f "tokens=2 delims==" %%i in ("!phone_navbar_raw!") do (
			set "phone_navbar_range=%%i"

			rem Handle the case where the phone's navbar dimension values are not = delimited
			if not defined phone_navbar_range (
				set "phone_navbar_range=0x0-0x0"

				color 0E
				mode 34, 18
				cls
				echo.
				echo  WARNING: PARSE FAILURE
				echo.
				echo  The output format for the phone
				echo  screen's navbar in pixels is
				echo  not stored as a key=value pair.
				echo.
				echo  Your version of Android may not
				echo  be compatible with the version
				echo  of adb installed.
				echo.
				echo  The script will continue, but
				echo  beware that there may be unknown
				echo  errors when calculating screen
				echo  tap values.
				echo.
				echo  Press any key to continue...
				pause > nul
			)

			rem Obtain the first y-tap-coordinate for the navigation bar
			for /f "tokens=2 delims=-" %%i in ("!phone_navbar_range!") do (
				set "phone_navbar_vals=%%i"

				for /f "tokens=1 delims=x" %%i in ("!phone_navbar_vals!") do (
					set "navheight=%%i"
				)

				rem Ensure that the navbar height value is numerical
				call :isnumerical !navheight!
				if "!foutput!"=="false" (
					set "navheight=!height!"

					color 0E
					mode 34, 18
					cls
					echo.
					echo  WARNING: BAD NAVHEIGHT VALUE
					echo.
					echo  The output format for the phone
					echo  screen's navbar in pixels was
					echo  not read as a numerical value.
					echo.
					echo  Your version of Android may not
					echo  be compatible with the version
					echo  of adb installed.
					echo.
					echo  The script will continue, but
					echo  beware that there may be unknown
					echo  errors when calculating screen
					echo  tap values.
					echo.
					echo  Press any key to continue...
					pause > nul
				)

				rem Change the navheight value to be a height rather than a coordinate
				set /a "navheight=height-navheight"
			)
		)

		timeout /t 3 /nobreak > nul
		cls
		echo.
		echo  Detected device: !width!x!navheight!-!height!px
		timeout /t 2 /nobreak > nul

		goto checkunlocked
	)
	
	goto:eof

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

:: Helper subroutine for selecting a bottom row button on the FEH gui.
:bottomrowselect
	:: Get the selected button's x-coordinate
	set "screenb=%~1"
	if [%~1]==[] (
		set "screenb=%home_fui%"
	)
	call :getpixelvalue !screenb! !width!
	set "x=!foutput!"

	call :getpixelvalue %bottom_row_fui% !height!
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

:: Converts decimal values to pixel values over a fixed-size dimension that can be sent over adb.
:getpixelvalue
	set "coord=%~1"
	if [%~1]==[] (
		set "coord=0"
	)

	set "dim=%~2"
	if [%~2]==[] (
		set "dim=0"
	)

	for /f "tokens=*" %%i in ('"echo v=(!coord! * !dim!);scale=0;v/1 | bc -l"') do set "foutput=%%i"	
	goto:eof

:: Checks that the argument given is a numerical value
:isnumerical
	set /a "numerical_test_value=%~1+0"

	if [!numerical_test_value!]==[%~1] (
		set "foutput=%~1"
		goto:eof
	)

	set "foutput=false"
	goto:eof

:: Calculates a random value between the provided values
:randrange
	set "b=%~1"
	set "a=%~2"

	call :isnumerical !b!
	if "!foutput!" == "false" set "b=0"

	call :isnumerical !a!
	if "!foutput!" == "false" set "a=1"

	:: Set a random value between 0 and 1 inclusive to p
	for /f "tokens=*" %%i in ('"echo %random% / 32797 | bc -l"') do set "p=%%i"

	:: Set the complementary value to q
	for /f "tokens=*" %%i in ('"echo 1 - !p! | bc -l"') set "q=%%i"

	:: Interpolate and set the output value for the function
	for /f "tokens=*" %%i in ('"echo !p! * !a! + !q! * !b! | bc -l"') set "foutput=%%i"

	goto:eof

:init
	color 07
	mode 44, 3
	cls
	echo.
	echo  FARMING HERO MERIT USING GIVEN SETTINGS...
	
	:: Initialization of the farming.
	call :bottomrowselect %battle_fui%


	goto:eof

:loop
	goto:eof

endlocal
