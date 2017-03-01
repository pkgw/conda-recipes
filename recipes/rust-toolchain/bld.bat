:: Trailing semicolon in this variable as set by current (2017/01)
:: conda-build breaks us. Manual fix:
set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"

bash configure --disable-docs --enable-clang --prefix=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
make -j%CPU_COUNT%
if errorlevel 1 exit 1
make install
if errorlevel 1 exit 1
