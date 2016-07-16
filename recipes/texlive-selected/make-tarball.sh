#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# This script builds a mega-tarball of TeX packages. This is necessary because
# Conda doesn't let us define a package with multiple source tarballs, and I
# don't want to ship a separate package for all of these stupid dependencies.
#
# If a certain file (say "expl3.sty") is needed, there are several ways to figure out
# which TexLive package might contain it.
#
# 1. Query on rpmfind.net:
#
#   https://www.rpmfind.net/linux/rpm2html/search.php?query=tex%28expl3.sty%29
#
# (the percent escaped characters are parentheses) However, this falls down
# with recent changes made in TexLive.
#
# 2. Create a local install of TeXLive, and use its tool. After installation, run something
# like:
#
#   $ tlmgr search --global --file expl3.sty
#
# This is definitely the best option since it stays up-to-date.
#
# 3. In the nuclear option, you can navigate the official SVN tree of
# everything here:
#
#   https://www.tug.org/svn/texlive/trunk/Master/
#
# If you can find the needed file in there, the commit messages sometimes
# indicate which tarballed package it goes into. The partitioning of files
# into TeXLive packages is defined in the configuration files here:
#
#   https://www.tug.org/svn/texlive/trunk/Master/tlpkg/tlpsrc/
#
# These also have the files such as "collections-basic.tlpsrc" that define the
# fundamental set of packages for a TeXLive distribution.

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
bibtex updir
booktabs none
caption none
cm none
cm-super none
collectbox none
courier none
dblfloatfix none
dehyph-exptl none
dvipdfmx updir
dvips updir
ec none
emulateapj none
enctex none
enumitem none
epsf none
etex none
etex-pkg none
etoolbox none
euenc none
eurosym none
fancyhdr none
fancyvrb none
filehook none
fontspec none
geometry none
glyphlist none
graphics none
graphics-cfg none
graphics-def none
gsftopk none
helvetic none
hyperref none
hyph-utf8 none
hyphen-afrikaans none
hyphen-ancientgreek none
hyphen-arabic none
hyphen-armenian none
hyphen-base none
hyphen-basque none
hyphen-bulgarian none
hyphen-catalan none
hyphen-chinese none
hyphen-churchslavonic none
hyphen-coptic none
hyphen-croatian none
hyphen-czech none
hyphen-danish none
hyphen-dutch none
hyphen-english none
hyphen-esperanto none
hyphen-estonian none
hyphen-ethiopic none
hyphen-farsi none
hyphen-finnish none
hyphen-french none
hyphen-friulan none
hyphen-galician none
hyphen-georgian none
hyphen-german none
hyphen-greek none
hyphen-hungarian none
hyphen-icelandic none
hyphen-indic none
hyphen-indonesian none
hyphen-interlingua none
hyphen-irish none
hyphen-italian none
hyphen-kurmanji none
hyphen-latin none
hyphen-latvian none
hyphen-lithuanian none
hyphen-mongolian none
hyphen-norwegian none
hyphen-occitan none
hyphen-piedmontese none
hyphen-polish none
hyphen-portuguese none
hyphen-romanian none
hyphen-romansh none
hyphen-russian none
hyphen-sanskrit none
hyphen-serbian none
hyphen-slovak none
hyphen-slovenian none
hyphen-spanish none
hyphen-swedish none
hyphen-thai none
hyphen-turkish none
hyphen-turkmen none
hyphen-ukrainian none
hyphen-uppersorbian none
hyphen-welsh none
ifluatex none
ifxetex none
knuth-lib none
knuth-local none
kpathsea updir,kpathsea
l3kernel none
l3packages none
lastpage none
latex none
latex-fonts none
latexconfig none
lineno none
lm none
makeindex updir
metafont updir
mflogo none
mfware updir
microtype none
ms none
natbib none
oberdiek none
pdftex updir
plain none
psnfss none
revtex none
revtex4 none
ruhyphen none
tetex updir
tex-gyre none
tex-gyre-math none
tex-ini-files none
texlive.infra updir
textcase none
times none
tipa none
titlesec none
tools none
ucharcat none
ucs none
ukrhyph none
ulem none
unicode-data none
unicode-math none
updmap-map none
url none
xcolor none
xetex updir
xkeyval none
xunicode none
zapfding none
EOF

cd ../unpacked
rm -rf readme-html.dir readme-txt.dir
rm -f index.html README README.usergroups
tar cjf ../"$tarbase".tar.bz2 *

cd "$origpwd"
mv "$work/$tarbase".tar.bz2 .
sha256sum "$tarbase".tar.bz2
rm -rf "$work"
