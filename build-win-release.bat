@echo OFF
setlocal

set QT_PATH="C:/Qt/6.8.0/msvc2022_64"
set VS_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build"
set CMAKE_PATH="C:\Qt\Tools\CMake_64\bin"
set NINJA_PATH="C:\Qt\Tools\Ninja"
set BUILD_DIR="build"

set PATH=%PATH%;%CMAKE_PATH%;%NINJA_PATH%

call %VS_PATH%"\vcvarsall.bat" x64
if %errorlevel% neq 0 (
    exit /b %errorlevel%
)

cmake.exe -B %BUILD_DIR% -S . -G "Ninja" --fresh -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%QT_PATH%
if %errorlevel% neq 0 (
    exit /b %errorlevel%
)

cmake.exe --build %BUILD_DIR% --config Release
if %errorlevel% neq 0 (
    exit /b %errorlevel%
)

cmake.exe --build %BUILD_DIR% --target package
if %errorlevel% neq 0 (
    exit /b %errorlevel%
)

endlocal
