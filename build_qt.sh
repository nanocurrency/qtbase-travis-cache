#!/usr/bin/env bash

prefix='/tmp/qt'
version='5.13.1'

while getopts 'hp:V:' OPT; do
	case "${OPT}" in
		h)
			echo "Usage: bootstrap_boost.sh [-h] [-p <prefix>] [-V <qtVersion>]"
			echo "   -h 		This help"
			echo "   -p <prefix>	Install prefix <prefix>"
			echo "   -V <qtVersion> Specify version of Boost to build"
			exit 0
			;;
		p)
			prefix="${OPTARG}"
			;;
		V)
			qtVersion="${OPTARG}"
			;;
	esac
done

set -o errexit
set -o xtrace
if [[ ! -d "$prefix/lib/cmake" ]]; then
	cd /tmp
	git clone https://code.qt.io/qt/qt5.git
	cd qt5
	git checkout -qf $version
	perl init-repository --module-subset=qtbase
	./configure -prefix $prefix -release -opensource \
    	        -confirm-license -system-zlib -qt-libpng -silent \
        	    -qt-libjpeg -qt-freetype -qt-pcre -nomake examples \
            	-nomake tests -rpath -pkg-config -dbus-runtime
	make -j2
	make install
fi

tar -czf $TRAVIS_BUILD_DIR/qtbase-$version.tgz $prefix
