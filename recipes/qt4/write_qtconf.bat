@echo off
setlocal enabledelayedexpansion
:: This file should be run after installing the qt4 package into any
:: environment.  It makes it so Qt4 knows where to look for includes and
:: libs.  This script is copied in bld.bat to the post-link script for qt4,
:: which means it is run after the Qt4 package gets linked, and sets up
:: the correct path for whatever Conda env you install Qt4 to.
pushd "%~dp0\..\"
set "FORWARD_SLASHED_PREFIX=%CD:\=/%"
if not exist "%CD%\Library" mkdir "%CD%\Library"
if not exist "%CD%\Library\qt4" mkdir "%CD%\Library\qt4"
if not exist "%CD%\Library\qt4\bin" mkdir "%CD%\Library\qt4\bin"
echo [Paths] > "%CD%\Library\qt4\bin\qt.conf"
echo Prefix = %FORWARD_SLASHED_PREFIX%/Library >> "%CD%\Library\qt4\bin\qt.conf"
echo Binaries = %FORWARD_SLASHED_PREFIX%/Library/qt4/bin >> "%CD%\Library\qt4\bin\qt.conf"
echo Libraries = %FORWARD_SLASHED_PREFIX%/Library/qt4/lib >> "%CD%\Library\qt4\bin\qt.conf"
echo Headers = %FORWARD_SLASHED_PREFIX%/Library/qt4/include >> "%CD%\Library\qt4\bin\qt.conf"
@echo on
