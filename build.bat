@echo off
REM Build the native Windows version of test_ood.
REM Usage: build.bat [debug^|release^|clean]
REM
REM Set RAYLIB_DIR to a raylib installation prefix when CMake cannot find it.
REM The directory should contain include\raylib.h and lib\raylib.lib.

setlocal
set "BUILD_DIR=build-win"
set "BUILD_TYPE=Release"

if /I "%~1"=="debug" (
    set "BUILD_TYPE=Debug"
) else if /I "%~1"=="release" (
    set "BUILD_TYPE=Release"
) else if /I "%~1"=="clean" (
    echo Cleaning %BUILD_DIR%...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    echo Clean complete.
    exit /b 0
) else if not "%~1"=="" (
    echo Usage: build.bat [debug^|release^|clean]
    exit /b 1
)

echo.
echo ==========================================
echo test_ood Windows Build
echo ==========================================
echo Build type: %BUILD_TYPE%
echo Build dir:  %BUILD_DIR%

if defined RAYLIB_DIR (
    echo raylib dir:  %RAYLIB_DIR%
    cmake -S . -B "%BUILD_DIR%" -DTARGET_PLATFORM=Windows -DCMAKE_BUILD_TYPE=%BUILD_TYPE% "-DRAYLIB_DIR=%RAYLIB_DIR%"
) else (
    echo raylib dir:  discovered by CMake
    cmake -S . -B "%BUILD_DIR%" -DTARGET_PLATFORM=Windows -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
)

if errorlevel 1 (
    echo CMake configuration failed.
    echo Set RAYLIB_DIR to your raylib installation prefix and try again.
    exit /b 1
)

cmake --build "%BUILD_DIR%" --config %BUILD_TYPE%
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

echo.
echo Build successful.
echo For Visual Studio generators: %BUILD_DIR%\%BUILD_TYPE%\test_ood.exe
echo For single-config generators: %BUILD_DIR%\test_ood.exe
