#!/bin/bash

cd test
$PREFIX/qt4/bin/qmake hello.pro
make
./hello
