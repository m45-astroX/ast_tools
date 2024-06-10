
# Makefile for radec2galaxy

# v1.0 by Yuma Aoki (Kindai Univ.)


TARGET = radec2galaxy

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

# Option
INCLUDE = -I$(HEADER_DIR)

default : all

all : $(TARGET)

$(OBJ) : $(SRC)
	$(CC) -o $@ $(INCLUDE) -c $^

$(TARGET) : $(OBJ)
	$(CC) $(OBJ) -o $@

clean :
	@rm -f $(TARGET) $(OBJ)
