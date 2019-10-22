#!/usr/bin/env bash

INSTALL_PATH='/tmp/rocksdb'
RocksDBVersion='6.3.6'
OS=`uname`

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
			INSTALL_PATH="${OPTARG}"
			;;
		V)
			RocksDBVersion="${OPTARG}"
			;;
	esac
done

set -o errexit
set -o xtrace
if [[ ! -d "$INSTALL_PATH/lib" ]]; then
	cd /tmp
	git clone https://github.com/facebook/rocksdb.git src
	cd src
	git checkout -qf "v$RocksDBVersion"
	export ROCKSDB_DISABLE_LZ4=1
	export ROCKSDB_DISABLE_SNAPPY=1
	export ROCKSDB_DISABLE_ZSTD=1
	export ROCKSDB_DISABLE_BZIP=1
	# build rocksdb (same as we do for gcc/clang in ci linux)
	PORTABLE=1 make static_lib && make install
fi

tar -czf $TRAVIS_BUILD_DIR/rocksdb-$OS-$RocksDBVersion.tgz $INSTALL_PATH