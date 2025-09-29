
# Makefile

# v1.0 by Yuma Aoki (Kindai Univ.)


TARGET = CALC_CROSS_SECTION

# Source
SRC_DIR = ./src
SRC = ${wildcard ${SRC_DIR}/*.c}

# Object
OBJ_DIR = ./obj
OBJ = $(patsubst ${SRC_DIR}/%.c,${OBJ_DIR}/%.o,$(SRC))

# Compiler
CC = gcc
CFLAGS = -Wall -O2

default : all

all : $(TARGET)

$(OBJ) : $(SRC)
	$(CC) -o $@ -c $^

$(TARGET) : $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $@

clean :
	@rm -f $(TARGET) $(OBJ)
