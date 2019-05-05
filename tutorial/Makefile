#
# Makefile for gstreamer
#
FLAGS=`pkg-config --cflags --libs gstreamer-1.0`
PROG=basic-tutorial-3

.PHONEY: edit build run clean

usage:
	@echo "make [edit|build|run|clean]"

edit e:
	vi $(PROG).c

build b: $(PROG).c
	gcc -o $(PROG) $(PROG).c $(FLAGS)

run r:
	./$(PROG)

clean:
	rm -f $(PROG)

