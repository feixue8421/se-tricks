SHELL = /bin/bash

CFLAGS = -Wall -g -std=c++11 -pthread
CC = g++
INCLUDES =
LIBS = -lm

EMPTY =
SPACE = $(EMPTY) $(EMPTY)
CURPATHS = $(subst /,$(SPACE),$(subst $(SPACE),_,$(CURDIR)))
TARGET = $(word $(words $(CURPATHS)),$(CURPATHS))

SOURCES = $(wildcard *.cpp)
OBJS = $(patsubst %.cpp, %.o, $(SOURCES))

.DEFAULT_GOAL := run

${TARGET}: ${OBJS}
	${CC} ${CFLAGS} -o $@ ${OBJS} ${LIBS}

clean:
	-rm -f ${OBJS} ${TARGET}

.cpp.o:
	${CC} ${CFLAGS} ${INCLUDES} -c $<

run: ${TARGET}
	./${TARGET}
	@echo -----------------DONE-----------------
	@read -n 1

