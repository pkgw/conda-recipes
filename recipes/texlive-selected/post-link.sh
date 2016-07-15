#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Generate the .fmt files, some of which embed absolute paths in a way that
# can't be patched up using Conda's standard methods. We don't want to annoy
# the user with reams of output if everything is OK, but we need to be
# debuggable if not, so we jump through some hoops. The logic below is based
# on some brief trial-and-error and may need improvement.

temp=$(mktemp)
for fmt in tex latex etex pdftex pdflatex pdfetex xetex xelatex ; do
    $PREFIX/bin/fmtutil-sys --byfmt $fmt >$temp 2>&1
    rc=$?
    if [ $rc -ne 0 ] ; then
	# Definite error.
	cat $temp >&2
	rm -f $temp
	exit 1
    fi
done

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

# Likewise, update the font mapping files. Very similar situation as above. Here we need
# to munge the config file but that's not too tricky. (Famous last words.)

tab="	" # <- embedded tab character
pfx="$PREFIX/share/texlive/texmf-dist/web2c"
cp $pfx/updmap-hdr.cfg $pfx/updmap.cfg
$PREFIX/bin/updmap-sys --listavailablemaps 2>/dev/null |grep "Map$tab" |awk '{print $1 " " $2}' >>$pfx/updmap.cfg
$PREFIX/bin/updmap-sys >$temp 2>&1
rc=$?
if [ $rc -ne 0 ] ; then
    # Definite error
    cat $temp >&2
    rm -f $temp
    exit 1
fi

# All done.

rm -f $temp
exit 0
