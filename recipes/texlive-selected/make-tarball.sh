#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# This script builds a mega-tarball of TeX packages. This is necessary because
# Conda doesn't let us define a package with multiple source tarballs, and I
# don't want to ship a separate package for all of these stupid dependencies.
#
# If a certain file (say "expl3.sty") is needed, a convenient way to guess
# which TeXLive package includes it is to consult the output of an rpmfind
# query:
#
#  https://www.rpmfind.net/linux/rpm2html/search.php?query=tex%28expl3.sty%29
#
# (the percent escaped characters are parentheses)

if [ -z "$1" ] ; then
    echo >&2 "usage: $0 <version>

Where the recommended version is of the form YYYYMMDD, e.g., 20160121"
    exit 1
fi

tarbase="texlive-selected-$1"
urlbase="http://mirrors.ctan.org/systems/texlive/tlnet/archive"
#urlbase="http://mirrors.acm.jhu.edu/ctan/systems/texlive/tlnet/archive"

work="$(mktemp -d)"
origpwd="$(pwd)"
cd "$work"
mkdir -p src unpacked/texmf-dist
cd src

while read pkg options ; do
    echo $pkg
    wget -q $urlbase/$pkg.tar.xz
    ###echo "$sha1 $(basename $pkg)" |sha1sum --check || exit 1

    dir=../unpacked/texmf-dist
    src=../../src
    filter="*"

    for option in $(echo $options |sed -e 's/,/ /g') ; do
	case $option in
	    updir)
		dir=../unpacked
		src=../src ;;
	    kpathsea)
		# This package includes some .tcx files that are wanted by
		# fmtutil, but also includes various web2c/ configuration
		# files that are provided by our texlive-core package, and the
		# versions in the tarball are Not What We Want. So with this
		# quasi-hack we extract only the desired files.
		filter='*.tcx' ;;
	    none)
		;;
	    *)
		echo unhandled option $option ; exit 1 ;;
	esac
    done

    (cd $dir && tar xJf $src/$pkg.tar.xz "$filter")
done <<EOF
adjustbox none
amsfonts none
amsmath none
booktabs none
caption none
cm none
cm-super none
collectbox none
dblfloatfix none
dehyph-exptl none
ec none
emulateapj none
enumitem none
epsf none
etex none
etex-pkg none
etoolbox none
euenc none
eurosym none
fancyvrb none
filehook none
fontspec none
geometry none
graphics none
helvetic none
hyperref none
hyph-utf8 none
hyphen-ancientgreek none
hyphen-base none
hyphen-german none
hyphen-greek none
ifluatex none
ifxetex none
knuth-lib none
kpathsea updir,kpathsea
l3kernel none
l3packages none
latex none
latex-fonts none
latexconfig none
lineno none
lm none
microtype none
ms none
natbib none
oberdiek none
pdftex updir
pdftex-def none
plain none
revtex none
revtex4 none
ruhyphen none
tex-gyre none
tex-gyre-math none
texlive.infra updir
textcase none
tipa none
titlesec none
tools none
ucharcat none
ucs none
ukrhyph none
ulem none
unicode-data none
unicode-math none
url none
xcolor none
xetex updir
xetex-def none
xkeyval none
xunicode none
zapfding none
EOF

cd ../unpacked
rm -rf texmf-dist/fonts/source readme-html.dir readme-txt.dir
rm -f index.html README README.usergroups
tar cjf ../"$tarbase".tar.bz2 *

cd "$origpwd"
mv "$work/$tarbase".tar.bz2 .
sha256sum "$tarbase".tar.bz2
rm -rf "$work"
