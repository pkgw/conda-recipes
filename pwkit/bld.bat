:: See http://docs.continuum.io/conda/build.html for a list of environment
:: variables that are set during the build process.

"%PYTHON%" setup.py install
if errorlevel 1 exit 1
