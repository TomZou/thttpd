#!/bin/bash
set -x

`dirname $0`/web_rsync.exp 10.211.55.8 root "root123" 22 `dirname $0`/../.. /root/thttpd -1
