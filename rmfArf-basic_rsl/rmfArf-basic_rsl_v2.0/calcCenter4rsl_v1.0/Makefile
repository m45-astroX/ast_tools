
# Makefile for calcCenter4rsl

# v1.0 by Yuma Aoki (Kindai Univ.)


TARGET = calcCenter4rsl

# Source
SRC_DIR = ./src
SRC = ${wildcard ${SRC_DIR}/*.c}

# Object
OBJ_DIR = ./obj
OBJ = $(patsubst ${SRC_DIR}/%.c,${OBJ_DIR}/%.o,$(SRC))

# Header
HEADER_DIR = ./inc

# Compiler
CC = gcc
CFLAGS = -Wall -O2
LIBS = -lcfitsio

ifeq ($(ENV), Linux)
	INCLUDE = -I/usr/local/adsoft/cfitsio/3.420/include
	LDFLAGS = -L/usr/local/adsoft/cfitsio/3.420/lib
else
	INCLUDE = -I$(HEADAS)/include -I$(HEADER_DIR)
	LDFLAGS = -L$(HEADAS)/lib -Wl,-rpath,$(HEADAS)/lib
endif

default : all

all : $(TARGET)

$(OBJ) : $(SRC)
	$(CC) -o $@ $(INCLUDE) $(CFLAGS) -c $^

$(TARGET) : $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $@ $(LIBS)

clean :
	@rm -f $(TARGET) $(OBJ)
