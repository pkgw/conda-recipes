#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# See build.sh -- I've decided to do this to make the DBus definitions accessible.

set -e
cd $PREFIX
sed -i .pre-dbus -e 's|#define QT_NO_DBUS|//QTDBC:#define QT_NO_DBUS|' \
     include/Qt/qfeatures.h include/QtCore/qfeatures.h
sed -i .pre-dbus -e 's|# \(undef|define\) QT_NO_DBUS|//QTDBC:# \1 QT_NO_DBUS|' \
     include/Qt/qconfig.h include/QtCore/qconfig.h
