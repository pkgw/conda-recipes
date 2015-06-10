#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

cd $PREFIX
exec bin/dbus-uuidgen >var/lib/dbus/machine-id
