# Makefile for libdns

CC=gcc

CFLAGS= -fPIC -Wall -Wextra -Wfloat-equal -std=c11 -std=gnu11 -fstack-protector-strong -O2

SFLAGS=-O
LDFLAGS= -Wl,--nxcompat -Wl,--dynamicbase -Wl,--no-seh -lws2_32
LDSHARED=gcc -shared
STRIP=strip

SHAREDLIB=../lib/libdns.dll
LDIR=../lib

SHELL=/bin/sh

SRCDIR=
INC=

SRCS=$(wildcard $(SRCDIR)*.c)
OBJS=$(notdir $(patsubst %.c, %.o, $(SRCS)))

%.o: $(SRCDIR)%.c
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<

$(SHAREDLIB): $(OBJS)
	$(shell mkdir -p $(dir $(SHAREDLIB)))
	$(LDSHARED) $(CFLAGS) -o $@ $(OBJS) $(LDSHAREDLIBC) $(LDFLAGS)
	$(STRIP) -s $(SHAREDLIB)

all: ../lib/libdns.dll

clean:
	rm -f *.o $(SHAREDLIB)

distclean: clean
	rm -f Makefile configure.log
	@if [ -f Makefile.in ]; then \
	printf 'all:\n\t-@echo "Please use ./configure first.  Thank you."\n' > Makefile ; \
	printf '\ndistclean:\n\tmake -f Makefile.in distclean\n' >> Makefile ; \
	touch -r $(SRCDIR)Makefile.in Makefile ; fi
