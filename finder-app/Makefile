# Compiler and flags
CC = gcc
CROSS_COMPILE ?=
CFLAGS = -Wall -Werror -g
TARGET = writer
SRC = writer.c
OBJ = $(SRC:.c=.o)

# If CROSS_COMPILE is set, use the cross-compiler
ifdef CROSS_COMPILE
    CC := $(CROSS_COMPILE)linux-gnu-gcc
endif

# Default build target
all: $(TARGET)

# Compile writer.c to writer.o, then link it into writer
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

# Compile .c to .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f $(TARGET) $(OBJ)
