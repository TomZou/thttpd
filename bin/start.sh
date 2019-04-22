#!/bin/bash

currDir=`pwd`
workDir=`dirname $0`

pidFile=thttpd.pid

cd ${workDir}

if [ -s $pidFile ]; then
	echo "ERROR: thttpd maybe already running! stop.sh first"
    exit
fi

./thttpd -C ../conf/ww.conf

cd ${currDir}
