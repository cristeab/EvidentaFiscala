set QT_PATH="C:/Qt/6.7.2/msvc2019_64"
set VS_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build"
set CMAKE_PATH="C:\Qt\Tools\CMake_64\bin"
set NINJA_PATH="C:\Qt\Tools\Ninja"

set PATH=%PATH%;%CMAKE_PATH%;%NINJA_PATH%

rmdir /S /Q  build

mkdir build
pushd build

call %VS_PATH%"\vcvarsall.bat" x64
if %errorlevel% neq 0 (
    popd
    exit /b %errorlevel%
)

cmake.exe .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%QT_PATH%
if %errorlevel% neq 0 (
    popd
    exit /b %errorlevel%
)

cmake.exe --build . --config Release
if %errorlevel% neq 0 (
    popd
    exit /b %errorlevel%
)

cmake.exe --build . --target package
if %errorlevel% neq 0 (
    popd
    exit /b %errorlevel%
)

popd
