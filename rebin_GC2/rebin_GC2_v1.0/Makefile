
CC = gcc
CFLAGS = -Wall -O2
OBJS = rebin_GC2.o
LIBS = -lcfitsio

INCLUDE = -I $(HEADAS)/include
LDFLAGS = -L $(HEADAS)/lib

rebin_GC2 : $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS) $(LIBS)

.c.o :
	$(CC) $(CFLAGS) $(INCLUDE) -c $<

clean : 
	rm -f rebin_GC2
	rm -f $(OBJS)
