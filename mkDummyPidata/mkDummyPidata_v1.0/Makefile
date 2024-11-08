
TARGET = mkDummyPiData

# Source
SRC_DIR = ./src
SRC = ${wildcard ${SRC_DIR}/*.c}

# Object
OBJ_DIR = ./obj
OBJ = $(patsubst ${SRC_DIR}/%.c,${OBJ_DIR}/%.o,$(SRC))

# Compiler
CC = gcc
CFLAGS = -Wall -O2
LIBS = -lcfitsio

ifeq ($(ENV), Linux)
	INCLUDE = -I/usr/local/adsoft/cfitsio/3.420/include
	LDFLAGS = -L/usr/local/adsoft/cfitsio/3.420/lib
else
	INCLUDE = -I$(HEADAS)/include
	LDFLAGS = -L$(HEADAS)/lib -Wl,-rpath,$(HEADAS)/lib
endif

all : $(TARGET)

$(OBJ) : $(SRC)
	$(CC) -o $@ $(INCLUDE) -c $^

$(TARGET) : $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $@ $(LIBS)

clean :
	@rm -f $(TARGET) $(OBJ)
