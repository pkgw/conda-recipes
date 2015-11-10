REM Copyright 2014-2015 Peter Williams and collaborators.
REM This file is licensed under a 3-clause BSD license; see LICENSE.txt.
REM It is also untested and probably broken.

"%PYTHON%" setup.py install
if errorlevel 1 exit 1
