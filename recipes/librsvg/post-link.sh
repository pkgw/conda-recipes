#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Make sure that the gdk-pixbuf loaders.cache is up-to-date; delegate to the
# centralized version to avoid endless copy-paste.

exec $PREFIX/bin/.gdk-pixbuf-post-link.sh
