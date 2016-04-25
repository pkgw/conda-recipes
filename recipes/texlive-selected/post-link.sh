#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Regenerate the .fmt files, some of which embed absolute paths in a way that
# can't be patched up using Conda's standard methods. We don't want to annoy
# the user with reams of output if everything is OK, but we need to be
# debuggable if not, so we jump through some hoops. The logic below is based
# on some brief trial-and-error and may need improvement.

temp=$(mktemp)
$PREFIX/bin/fmtutil-sys --all >$temp 2>&1
rc=$?
if [ $rc -ne 0 ] ; then
    # Definite error.
    cat $temp >&2
else
    # Just in case, dump things that look like warnings and errors,
    # specifically ignoring a few that we know we don't care about. We could
    # potentially signal failure if we see an ERROR in the log with a zero
    # exitcode, but that seems too fragile.
    #
    # Examples of types of messages we're choosing to ignore:
    #
    #   fmtutil [WARNING]: inifile eptex.ini for eptex/eptex not found.
    #   fmtutil [ERROR]: not building luajittex due to missing engine luajittex.
    grep -iE '(warning|error)' $temp |grep -v 'inifile.*not found' |grep -v 'missing engine' >&2
fi

rm -f $temp
exit $rc
