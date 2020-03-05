@ECHO OFF
:mainmenu 
CLS
ECHO ***********Menu***********
ECHO __________________________

ECHO 1.Start Clean UP 
ECHO 2.Display Active Drives
ECHO 3.List All Active Processes
ECHO 4.Boot Information
ECHO 5.Shutdown
ECHO.

CHOICE /C 12345 /M "Enter your choice:"

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 5 GOTO Shutdown
IF ERRORLEVEL 4 GOTO BootInfo
IF ERRORLEVEL 3 GOTO ListAllActiveWindows
IF ERRORLEVEL 2 GOTO DisplayDrives
IF ERRORLEVEL 1 GOTO CleanUp

:CleanUp
ECHO Clean Up (
	@echo off

echo Cleaning system junk files, please wait...
REM displays a line of text

del /f /s /q %systemdrive%\*.tmp
del /f /s /q %systemdrive%\*._mp
del /f /s /q %systemdrive%\*.log
del /f /s /q %systemdrive%\*.gid
del /f /s /q %systemdrive%\*.chk
del /f /s /q %systemdrive%\*.old
del /f /s /q %systemdrive%\recycled\*.*
del /f /s /q %windir%\*.bak
del /f /s /q %windir%\prefetch\*.*
rd /s /q %windir%\temp & md %windir%\temp
del /f /q %userprofile%\cookies\*.*
del /f /q %userprofile%\recent\*.*
del /f /s /q “%userprofile%\Local Settings\Temporary Internet Files\*.*”
del /f /s /q “%userprofile%\Local Settings\Temp\*.*”
del /f /s /q “%userprofile%\recent\*.*”

REM /f: force deleting of read-only files
REM /s: Delete specified files from all subdirectories.
REM /q: Quiet mode, do not ask if ok to delete on global wildcard
REM %systemdrive%: drive upon which the system folder was placed
REM %windir%: a regular variable and is defined in the variable store as %SystemRoot%. 
REM %userprofile%: variable to find the directory structure owned by the user running the process

echo Cleaning of junk files is finished!
REM displays a line of text

echo. & pause
REM echo.: Displays a single blank line on the screen.
REM pause: This will stop execution of the batch file until someone presses "any key"

pause 
goto mainmenu 
	)

:Shutdown
ECHO Shutdown (
	shutdown /s /f /t 0
	)
GOTO End

:ListAllActiveWindows
ECHO List All Active Processes (
wmic process get caption

REM displays a line of text
echo. & pause
REM echo.: Displays a single blank line on the screen.
REM pause: This will stop execution of the batch file until someone presses "any key"

pause 
goto mainmenu 
	)
GOTO End

:BootInfo
ECHO Boot Information (

	@ECHO OFF
ECHO.

:: Check Windows version (XP Pro or later) and command line arguments (none)
IF NOT "%OS%"=="Windows_NT"    GOTO Syntax
IF NOT "%~1"==""               GOTO Syntax
WMIC.EXE Alias /? >NUL 2>&1 || GOTO Syntax

:: Retrieve drive info
FOR /F "tokens=1* delims==" %%A IN ('WMIC Path Win32_DiskPartition Where "BootPartition=true And PrimaryPartition=true" Get DeviceID /Format:list') DO IF NOT "%%~B"=="" SET BootPartition=%%B
FOR /F "tokens=1 delims=[]" %%A IN ('WMIC Path Win32_LogicalDiskToPartition Get Antecedent^,Dependent /Format:list ^| FIND /N "=" ^| FIND /I "%BootPartition%"') DO SET LineNum=%%A
SET /A LineNum+=1
FOR /F "tokens=3 delims=="  %%A IN ('WMIC Path Win32_LogicalDiskToPartition Get Antecedent^,Dependent /Format:list ^| FIND /N "=" ^| FINDSTR /B /L /C:"\[%LineNum%\]"') DO SET BootDrive=%%~A

:: Format output
FOR /F "tokens=1,2 delims=," %%A IN ("%BootPartition%") DO (
	SET BootDisk=%%A
	SET BootPartition=%%B
)
SET BootPartition=%BootPartition:~1%
SET BootDrive=%BootDrive:"=%

:: Display the results:
SET Boot

REM displays a line of text
echo. & pause
REM echo.: Displays a single blank line on the screen.
REM pause: This will stop execution of the batch file until someone presses "any key"

pause 
goto mainmenu
:: Done
GOTO:EOF
)


:DisplayDrives
ECHO Display Active Drives (
@ECHO OFF
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax

:: Check if WMIC is available
WMIC.EXE /? >NUL 2>&1 || GOTO Syntax

:: keep variables local
SETLOCAL ENABLEDELAYEDEXPANSION

:: Command line parsing
IF NOT "%~2"=="" GOTO Syntax

SET AcceptDriveTypes=0
SET Numeric=0
IF /I "%~1"==""   SET AcceptDriveTypes=23456
IF /I "%~1"=="/C" SET AcceptDriveTypes=5
IF /I "%~1"=="/F" SET AcceptDriveTypes=3
IF /I "%~1"=="/L" SET AcceptDriveTypes=2356
IF /I "%~1"=="/N" SET AcceptDriveTypes=4
IF /I "%~1"=="/R" SET AcceptDriveTypes=25
IF /I "%~1"=="/T" SET AcceptDriveTypes=23456
IF /I "%~1"=="/T" SET Numeric=1
IF %AcceptDriveTypes% EQU 0 (
	SET Arg=%~1
	IF /I "!Arg:~0,3!"=="/T:" (
		REM *** Add 1 as prefix, and remove it again, to
		REM *** prevent interpretation of leading zero as octal
		SET /A AcceptDriveTypes = 1!Arg:~3!
		SET AcceptDriveTypes=!AcceptDriveTypes:~1!
		SET Numeric=1
	)
)

:: If AcceptDriveTypes is zero, an invalid command line argument was passed
IF %AcceptDriveTypes% EQU 0 (
	ENDLOCAL
	GOTO Syntax
)

:: WMIC query to list all drive letters and drive types
FOR /F "tokens=2,3* delims=," %%A IN ('WMIC.EXE /Node:"%Node%" /Output:STDOUT Path Win32_LogicalDisk Get DeviceID^,Description^,DriveType /Format:CSV ^| FINDSTR /R /C:",[A-Z]:"') DO (
	REM Add an extra FOR loop to remove the linefeed from %%C
	FOR %%D IN (%%C) DO (
		ECHO.%AcceptDriveTypes% | FIND "%%~D" >NUL
		IF NOT ERRORLEVEL 1 (
			IF %Numeric% EQU 1 (
				ECHO.  %%B      %%C
			) ELSE (
				ECHO.  %%B      %%A
			)
		)
	)
)
REM displays a line of text
echo. & pause
REM echo.: Displays a single blank line on the screen.
REM pause: This will stop execution of the batch file until someone presses "any key"

pause 
goto mainmenu
:: Done
ENDLOCAL
GOTO:EOF


	)
GOTO End

:End