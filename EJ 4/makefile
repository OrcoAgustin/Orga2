CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = printFijos

all: $(TARGET)

$(TARGET): printFijos.o
	$(CC) $(CFLAGS) $^ -o $@

printFijos.o: printFijos.c
	$(CC) $(CFLAGS) -c $< -o $@	

clean:
	rm *.o $(TARGET)

.PHONY: all clean