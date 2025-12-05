
CC = gcc
CFLAGS = -Wall -O2
OBJS = rebin_eq_intervals.o
LIBS = -lcfitsio

INCLUDE = -I $(HEADAS)/include
LDFLAGS = -L $(HEADAS)/lib

rebin_eq_intervals : $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS) $(LIBS)

.c.o :
	$(CC) $(CFLAGS) $(INCLUDE) -c $<

clean : 
	rm -f rebin_eq_intervals
	rm -f $(OBJS)
