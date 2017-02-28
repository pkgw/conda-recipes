QT       += core
QT       -= gui
TARGET = hello
CONFIG   += console
CONFIG   -= app_bundle
TEMPLATE = app
SOURCES += main.cpp
# so it can find the Qt libraries
QMAKE_RPATHDIR += $$(PREFIX)/lib
