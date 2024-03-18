@echo off
setlocal

rem Get parameters
set "HOST_PORT=%~1"
set "TIMEOUT=%~2"
set "COMMAND=%~3"

rem Extract host and port from HOST_PORT
for /f "tokens=1,2 delims=:" %%a in ("%HOST_PORT%") do (
    set "HOST=%%a"
    set "PORT=%%b"
)

rem Validate host and port
if "%HOST%"=="" (
    echo Error: Host is not specified.
    exit /b 1
)

if "%PORT%"=="" (
    echo Error: Port is not specified.
    exit /b 1
)

rem Set default timeout if not specified
if "%TIMEOUT%"=="" set "TIMEOUT=15"

rem Wait for the specified host and port
echo Waiting %TIMEOUT% seconds for %HOST%:%PORT%
set "START_TIME=%time%"
set "ELAPSED_SECONDS=0"
:LOOP
(
    echo. | telnet %HOST% %PORT% 2>NUL | find /i "Escape character" >NUL
) && (
    set "END_TIME=%time%"
    echo %HOST%:%PORT% is available after %END_TIME%
    goto :EXECUTE_COMMAND
) || (
    timeout /t 1 >NUL
    set "CURRENT_TIME=%time%"
    rem Calculate time difference
    for /f "tokens=1-4 delims=:., " %%a in ("%CURRENT_TIME%") do (
        set /a "ELAPSED_SECONDS=((((1%%a*60)+1%%b)*60)+1%%c)*100+1%%d - (((((1%START_TIME:~0,2%*60)+1%START_TIME:~3,2%)*60)+1%START_TIME:~6,2%)*100+1%START_TIME:~9,2%)"
    )
    rem Check if timeout reached
    if %ELAPSED_SECONDS% geq %TIMEOUT%000 (
        echo Timeout occurred after waiting %TIMEOUT% seconds for %HOST%:%PORT%
        exit /b 1
    ) else (
        goto :LOOP
    )
)

:EXECUTE_COMMAND
rem Execute the specified command
if not "%COMMAND%"=="" (
    echo Executing command: %COMMAND%
    call %COMMAND%
)

endlocal
