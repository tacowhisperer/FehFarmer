:: GLWT(Good Luck With That) Public License
:: Copyright (c) Everyone, except Author
:: 
:: The author has absolutely no clue what the code in this project does.
:: It might just work or not, there is no third option.
:: 
:: Everyone is permitted to copy, distribute, modify, merge, sell, publish,
:: sublicense or whatever they want with this software but at their OWN RISK.
:: 
:: 
::                 GOOD LUCK WITH THAT PUBLIC LICENSE
::    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION, AND MODIFICATION
:: 
:: 0. You just DO WHATEVER YOU WANT TO as long as you NEVER LEAVE A
:: TRACE TO TRACK THE AUTHOR of the original product to blame for or hold
:: responsible.
:: 
:: IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
:: WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
:: CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
:: 
:: Good luck and Godspeed.
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

:: adb accelerometer values
set "stay_in_current_rotation=0"
set "rotate_screen_content=1"

:: Function output container.
set "foutput=null"

:: Fire Emblem...*inhales*... HEROES!!!
set "welcome_x_fui=0.5"
set "welcome_y_fui=0.78"

:: Banners available pop-up coordinates to close the screen
for /f "tokens=*" %%i in ('"echo 590 / 740 | bc -l"') do set "banners_x_fui=%%i"
for /f "tokens=*" %%i in ('"echo 1073 / 1280 | bc -l"') do set "banners_y_pui=%%i"

:: Notifications from Nintendo using the phone user interface (pui)
for /f "tokens=*" %%i in ('"echo 985 / 1080 | bc -l"') do set "notifications_x_pui=%%i"

:: Celebration bonuses (big golden screens with the bread of every day)
for /f "tokens=*" %%i in ('"echo 500 / 740 | bc -l"') do set "celebration_bonus_x_fui=%%i"
for /f "tokens=*" %%i in ('"echo 1002 / 1280 | bc -l"') do set "celebration_bonus_y_fui=%%i"

:: Daily log-in bonus popup (usually dueling swords or feathers)
set "daily_login_bonus_x_fui=0.5"
for /f "tokens=*" %%i in ('"echo 807.5 / 1280 | bc -l"') do set "daily_login_bonus_y_pui=%%i"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Bottom row of buttons on the main FEH user interface (fui).        ::
:: These are fractional values based on the FUI display ratio (37:64) ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for /f "tokens=*" %%i in ('"echo 1230 / 1280 | bc -l"') do set "bottom_row_pui=%%i"

:: Home screen coordinates
for /f "tokens=*" %%i in ('"echo 66.00 / 740 | bc -l"') do set "home_fui=%%i"

:: Battle screen coordinates
for /f "tokens=*" %%i in ('"echo 187.5 / 740 | bc -l"') do set "battle_fui=%%i"
	:: Column values
	for /f "tokens=*" %%i in ('"echo 188 / 740 | bc -l"') do set "left_battle_column_fui=%%i"
	for /f "tokens=*" %%i in ('"echo 542 / 740 | bc -l"') do set "right_battle_column_fui=%%i"

	:: Blessed Gardens
	set "blessedg_x_fui=!left_battle_column_fui!"
	set "blessedg_y_pui=0.25"

	:: Special Maps
	set "specialmaps_x_fui=!right_battle_column_fui!"
	set "specialmaps_y_pui=0.25"
		set "specialmaps_screen_x_pui=0.5"
		for /f "tokens=*" %%i in ('"echo 343 / 1280 | bc -l"') do set "specialmaps_top_pui=%%i"
		for /f "tokens=*" %%i in ('"echo 1139 / 1280 | bc -l"') do set "specialmaps_bottom_pui=%%i"
		for /f "tokens=*" %%i in ('"echo 164 / 1280 | bc -l"') do set "specialmaps_height_pui=%%i"
		for /f "tokens=*" %%i in ('"echo 43 / 1280 | bc -l"') do set "specialmaps_margin_pui=%%i"

	:: Story Maps
	set "storymaps_x_fui=!left_battle_column_fui!"
	set "storymaps_y_pui=0.5"

	:: Arena Duels
	set "arenaduels_x_fui=!right_battle_column_fui!"
	set "arenaduels_y_pui=0.5"

	:: Training Tower
	set "trainingt_x_fui=!left_battle_column_fui!"
	set "trainingt_y_pui=0.75"

	:: Events
	set "events_x_fui=!right_battle_column_fui!"
	set "events_y_pui=0.75"

	:: Universal battle selection coordinates (diamond-shaped boxes)
	:: These are used in many of the different battle selection screens right before
	:: starting a battle.
	set "universal_diamond_x_fui=0.5"
	for /f "tokens=*" %%i in ('"echo 330 / 1280 | bc -l"') do set "universal_diamond_top_pui=%%i"
	for /f "tokens=*" %%i in ('"echo 1138 / 1280 | bc -l"') do set "universal_diamond_bottom_pui=%%i"
	for /f "tokens=*" %%i in ('"echo 190 / 1280 | bc -l"') do set "universal_diamond_height_pui=%%i"
	for /f "tokens=*" %%i in ('"echo 30 / 1280 | bc -l"') do set "universal_diamond_margin_pui=%%i"

:: Allies screen coordinates
for /f "tokens=*" %%i in ('"echo 308.5 / 740 | bc -l"') do set "allies_fui=%%i"

:: Summon screen coordinates
for /f "tokens=*" %%i in ('"echo 430.0 / 740 | bc -l"') do set "summon_fui=%%i"

:: Shop screen coordinates
for /f "tokens=*" %%i in ('"echo 551.0 / 740 | bc -l"') do set "shop_fui=%%i"

:: Misc. screen coordinates
for /f "tokens=*" %%i in ('"echo 672.5 / 740 | bc -l"') do set "misc_fui=%%i"

:: First tap location
rem set "app_init_x=916"
rem set "app_init_y=885"

mode 50, 3
echo.
echo   INITIALIZING...

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

:: Obtains the screen size of the connected device in pixels (and the FEH screen size)
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

			rem Also calculate the FEH screen size
			for /f "tokens=*" %%i in ('"echo v=(37 / 64 * !height!);scale=0;v/1 | bc -l"') do set "feh_width=%%i"
			set "feh_height=!height!"

			rem Finally, calculate the delta value for adjusting percentages from feh (fui) to phone (pui)
			for /f "tokens=*" %%i in ('"echo (!feh_width! - !width!) / 2 | bc -l"') do set "delta=%%i"

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

				for /f "tokens=1 delims=x" %%i in ("!phone_navbar_vals!") do set "navheight=%%i"

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

		rem Also calculate the FEH screen size
		for /f "tokens=*" %%i in ('"echo v=(37 / 64 * !height!);scale=0;v/1 | bc -l"') do set "feh_width=%%i"
		set "feh_height=!height!"

		rem Finally, calculate the delta value for adjusting percentages from feh (fui) to phone (pui)
		for /f "tokens=*" %%i in ('"echo (!feh_width! - !width!) / 2 | bc -l"') do set "delta=%%i"

		timeout /t 3 /nobreak > nul
		cls
		echo.
		echo  Detected device: !width!x!navheight!-!height!px
		timeout /t 2 /nobreak > nul

		goto checkunlocked
	)
	
	goto:eof

:: Ensure that the device is unlocked.
:checkunlocked
	::Source
	::https://stackoverflow.com/questions/35275828/is-there-a-way-to-check-if-android-device-screen-is-locked-via-adb/35276479

	:: Check that the device is unlocked
	adb shell dumpsys nfc | find "mScreenState=" | find "UNLOCKED" > nul
	if [%errorlevel%]==[0] (
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
		timeout /t 1 /nobreak > nul

		goto checkunlocked
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
	if defined feh_in_bg (
		goto init
	)

	color 07
	mode 50, 4
	cls
	echo.
	echo  Launching FEH...


	:: Give the app time to open and load before continuing. This time is overkill on any decent phone/internet.
	timeout /t 30 /nobreak

	:: Ensure that FEH is the focused app right now, and if not, it's not installed.
	adb shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'" | find "com.nintendo.zaba" > nul

	if not [%errorlevel%]==[0] (
		color 0C
		mode 44, 11
		cls
		echo.
		echo  ERROR: FE HEROES IS NOT INSTALLED^^!
		echo.
		echo  Make sure that it is properly installed,
		echo  the tutorial is finished, all rewards have
		echo  been claimed, and you are on the home
		echo  screen. Then, feel tree to try again.
		echo.
		echo  If you keep seeing this message, there is
		echo  something wrong with adb and it must be
		echo  addressed.
		echo.
		echo  Press any key to exit...
		pause > nul

		exit
	)

	cls
	echo.
	echo  Loading FEH...

	:: Calculate the center of the screen and tap it
	call :getphonepixelvalue %welcome_x_fui%
	set "x=!foutput!"
	call :getpixelvalue %welcome_y_fui% !height!
	set "y=!foutput!"

	adb shell input tap !x! !y! > nul

	timeout /t 30 /nobreak

	:: Calculate the currently active banners close button and tap it 5 times
	cls
	echo.
	echo  Currently active banners...
	call :getphonepixelvalue %banners_x_fui%
	set "x=!foutput!"
	call :getpixelvalue %banners_y_pui% !height!
	set "y=!foutput!"
	for /l %%i in (1,1,5) do adb shell input tap !x! !y! > nul

	:: Calculate the exit button for the notifications and tap it 5 times
	cls
	echo.
	echo  Notifications from Nintendo...
	call :getphonepixelvalue %notifications_x_pui%
	set "x=!foutput!"
	for /f "tokens=*" %%i in ('"echo v=(!height! - (1.5 * !navheight!));scale=0;v/1 | bc -l"') do set "y=%%i"
	for /l %%i in (1,1,5) do adb shell input tap !x! !y! > nul

	:: Calculate the "Celebration Bonus" close button and tap it 5 times
	cls
	echo.
	echo  "Celebration Bonus"...
	call :getphonepixelvalue %celebration_bonus_x_fui%
	set "x=!foutput!"
	call :getpixelvalue %celebration_bonus_y_fui% !height!
	set "y=!foutput!"
	for /l %%i in (1,1,5) do adb shell input tap !x! !y! > nul

	:: Finally, calculate the daily log-in close button and tap it 5 times
	cls
	echo.
	echo  Daily Log-In Bonus...
	call :getphonepixelvalue %daily_login_bonus_x_fui%
	set "x=!foutput!"
	call :getpixelvalue %daily_login_bonus_y_pui% !height!
	set "y=!foutput!"
	for /l %%i in (1,1,5) do adb shell input tap !x! !y! > nul

	goto init

	:: Control-flow should never reach this statement
	mode 43, 11
	color 0C
	cls
	echo.
	echo  FATAL ERROR: CONTROL FLOW MIS-EXECUTION
	echo.
	echo  This message must never be shown on the
	echo  screen. If you are seeing this message,
	echo  something went horribly, HORRIBLY wrong
	echo  with the program.
	echo.
	echo  Press any key to spray holy water on your
	echo  PC, call an exorcist, and gtfo...
	pause > nul
	goto:eof

:: Helper subroutine for selecting a bottom row button on the FEH gui.
:bottomrowselect
	:: Get the selected button's x-coordinate
	set "screenb=%~1"
	if [%~1]==[] (set "screenb=%home_fui%")
	call :getphonepixelvalue !screenb!
	set "x=!foutput!"

	call :getpixelvalue %bottom_row_pui% !height!
	set "y=!foutput!"

	:: Send the command over adb
	adb shell input tap !x! !y! > nul
	timeout /t 1 /nobreak > nul
	goto:eof

:: Specialty subroutine for the :bottomrowselect %battle_fui% subroutine to enter the special maps
:specialmapsscreen
	:: Calculate the right column pixel value
	call :getphonepixelvalue %right_battle_column_fui%
	set "x=!foutput!"

	:: Calculate the pixel value for the special maps battle option
	call :getpixelvalue %specialmaps_y_pui% !height!
	set "y=!foutput!"

	:: Go to the special maps screen
	adb shell input tap !x! !y! > nul
	timeout /t 1 /nobreak > nul

	goto:eof

:: Specialty subroutine for selecting a rectangular box like the ones found in the special maps screen.
:rectangularlistselect
	set "element=%~1"
	call :isnumerical !element!
	if "!foutput!"=="false" (set "element=1")

	set "num_elements=%~2"
	call :isnumerical !num_elements!
	if "!foutput!"=="false" (set "num_elements=1")

	:: specialmaps_top_pui, specialmaps_bottom_pui, specialmaps_margin_pui, specialmaps_height_pui

	goto:eof

:: Converts decimal values to pixel values over a fixed-size dimension that can be sent over adb.
:getpixelvalue
	set "percentage=%~1"
	if [%~1]==[] (set "percentage=0")

	set "dim=%~2"
	if [%~2]==[] (set "dim=0")

	for /f "tokens=*" %%i in ('"echo v=(!percentage! * !dim!);scale=0;v/1 | bc -l"') do set "foutput=%%i"

	goto:eof

:: Converts feh decimal values to phone decimal values over width, and then to pixel values for adb.
:getphonepixelvalue
	set "feh_percentage=%~1"
	if [%~1]==[] (set "feh_percentage=0")

	for /f "tokens=*" %%i in ('"echo ((!feh_percentage! * !feh_width!) - !delta!) / !width! | bc -l"') do set "perzentage=%%i"

	call :getpixelvalue !perzentage! !width!

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
	if "!foutput!" == "false" (set "b=0")

	call :isnumerical !a!
	if "!foutput!" == "false" (set "a=1")

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
	call :specialmapsscreen

	goto:eof

:loop
	goto:eof

endlocal
