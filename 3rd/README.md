## lua

源码来自 http://www.lua.org/
版本 5.3.5

#### 修改
无

#### 编译方法
macosx的编译方法`make macosx`
linux的编译方法`make linux`

## lua-cjson

源码来自 https://github.com/cloudwu/lua-cjson
版本： https://github.com/cloudwu/lua-cjson/commit/b5b6d3b9287a38ca2697ce66a834cccd41b6019a

#### 修改
在源码基础上修改了Makefile

#### 编译安装方法
macosx的编译方法`make PLAT=macosx`
linux的编译方法`make`
`make install`会把编译好的so拷贝到lualibc目录

## lua-md5

参见 lua-md5/README， 实际是从skynet/3rd/lua-md5里抠出来的

#### 修改
增加Makefile

#### 编译安装方法
macosx的编译方法`make PLAT=macosx`
linux的编译方法`make`
`make install`会把编译好的so拷贝到lualibc目录
