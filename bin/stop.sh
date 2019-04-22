#!/bin/bash

currDir=`pwd`
workDir=`dirname $0`

pidFile=thttpd.pid

cd ${workDir}

if [ -s $pidFile ]; then
	pid=$(cat $pidFile)
	kill -9 $pid
	rm -rf $pidFile
fi

cd ${currDir}
