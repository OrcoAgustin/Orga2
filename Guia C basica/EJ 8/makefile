CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = main

all: $(TARGET)

$(TARGET): main.o
	$(CC) $(CFLAGS) $^ -o $@

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@	

clean:
	rm *.o $(TARGET)

.PHONY: all clean