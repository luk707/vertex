CC = gcc
CFLAGS = -Wall -Wextra -O2 -DWLR_USE_UNSTABLE -I/usr/include/pixman-1
LDFLAGS = $(shell pkg-config --libs wlroots xkbcommon wayland-server pixman-1)
TARGET = mervin
SRCS = mervin.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS) $(LDFLAGS)

clean:
	rm -f $(TARGET)
