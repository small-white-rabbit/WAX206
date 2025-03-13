CC = gcc
CFLAGS =
WFLAGS = -Wall -Werror
makePartHeader-objs = mk_header.o
LDFLAGS = -lm

all: makePartHeader

%.o: %.c
	$(CC) $(CFLAGS) $(WFLAGS) -c -o $@ $<

makePartHeader: $(makePartHeader-objs)
	$(CC) -o $@ $(makePartHeader-objs) $(LDFLAGS)

clean:
	rm -f makePartHeader *.o
