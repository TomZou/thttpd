PWDPATH  = $(shell pwd)
PLAT ?= linux

##### Build defaults #####
TARGET =            md5.so
CFLAGS =            -O3 -Wall -pedantic -DNDEBUG
CJSON_CFLAGS =      -fpic
CJSON_LDFLAGS =     -shared
LUA_INCLUDE_DIR =   $(PWDPATH)/../lua/src
LUA_CMODULE_DIR =   $(PWDPATH)/../../lualibc
LUA_MODULE_DIR =    $(PWDPATH)/../../lualib

CC= gcc
AR= gcc -o

##### Platform overrides #####

## Linux

## FreeBSD
#LUA_INCLUDE_DIR =   $(PREFIX)/include/lua51

## MacOSX (Macports)
#PREFIX =            /opt/local
#CJSON_LDFLAGS =     -bundle -undefined dynamic_lookup
ifeq ($(PLAT), macosx)
	MYENV = 			env MACOSX_DEPLOYMENT_TARGET='10.11'
	CFLAGS = 			-O2 -fno-common -Wall -pedantic
	CJSON_CFLAGS =
	CJSON_LDFLAGS =     -bundle -undefined dynamic_lookup
endif

##### End customisable sections #####

EXECPERM =          755
BUILD_CFLAGS =      -I$(LUA_INCLUDE_DIR) $(CJSON_CFLAGS)
OBJS =              md5.o md5lib.o compat-5.2.o

.PHONY: all clean install

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(BUILD_CFLAGS) -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJS)
	$(AR) $@ $(LDFLAGS) $(CJSON_LDFLAGS) $(OBJS)

install: $(TARGET)
	mkdir -p $(DESTDIR)/$(LUA_CMODULE_DIR)
	cp $(TARGET) $(DESTDIR)/$(LUA_CMODULE_DIR)
	chmod $(EXECPERM) $(DESTDIR)/$(LUA_CMODULE_DIR)/$(TARGET)

clean:
	rm -f *.o $(TARGET)
