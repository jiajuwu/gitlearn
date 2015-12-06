
exec_prefix = ${prefix}
prefix = /usr/local

includedir = $(DESTDIR)${prefix}/include
libdir = $(DESTDIR)${exec_prefix}/lib
datadir = $(DESTDIR)${prefix}/share

AR = ar
CC = gcc
CFLAGS = -g -O2
LDFLAGS = 
SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)
INC = -I.

ifeq ($(shell uname),Darwin)
	SO_EXT := dylib
else
	SO_EXT := so
	CFLAGS := -fPIC $(CFLAGS)
endif

SO_NAME := libjsonparser.$(SO_EXT).1.0
REAL_NAME = libjsonparser.$(SO_EXT).1.1.0

all: libjsonparser.a libjsonparser.$(SO_EXT) examples/test-json

libjsonparser.a: $(OBJS)
	$(AR) rcs libjsonparser.a json.o

libjsonparser.so: $(OBJS)
	$(CC) -shared -Wl,-soname,$(SO_NAME) -o libjsonparser.so $^

libjsonparser.dylib: $(OBJS)
	$(CC) -dynamiclib json.o -o libjsonparser.dylib

examples/test-json:examples/test_json.o json.o
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $^

examples/test_json.o:
	$(CC) $(CFLAGS) $(INC) -c examples/test_json.c -o $@

clean:
	rm -f libjsonparser.$(SO_EXT) libjsonparser.a json.o examples/test-json examples/test_json.o

install-shared: libjsonparser.$(SO_EXT)
	@echo Installing pkgconfig module: $(datadir)/pkgconfig/json-parser.pc
	@install -d $(datadir)/pkgconfig/ || true
	@install -m 0644 json-parser.pc $(datadir)/pkgconfig/json-parser.pc
	@echo Installing shared library: $(libdir)/libjsonparser.$(SO_EXT)
	@install -d $(libdir) || true
	@install -m 0755 libjsonparser.$(SO_EXT) $(libdir)/$(REAL_NAME)
	@rm -f $(libdir)/$(SO_NAME)
	@ln -s $(REAL_NAME) $(libdir)/$(SO_NAME)
	@rm -f $(libdir)/libjsonparser.$(SO_EXT)
	@ln -s $(SO_NAME) $(libdir)/libjsonparser.$(SO_EXT)
	@install -d $(includedir)/json-parser || true
	@install -m 0644 ./json.h $(includedir)/json-parser/json.h

install-static: libjsonparser.a
	@echo Installing static library: $(libdir)/libjsonparser.a
	@install -m 0755 libjsonparser.a $(libdir)/libjsonparser.a
	@install -d $(includedir)/json-parser || true
	@install -m 0644 ./json.h $(includedir)/json-parser/json.h

install: install-shared install-static
	@echo Compiler flags: -I$(includedir)/json-parser
	@echo Linker flags: -L$(libdir) -ljsonparser

.PHONY: all clean install install-shared install-static


