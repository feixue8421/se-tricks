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
OBJS = $(SOURCES:.cpp=.o)
DEPS = $(SOURCES:.cpp=.d)

.DEFAULT_GOAL := run

$(TARGET): $(DEPS) $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	-rm -f $(OBJS) $(DEPS) $(TARGET)

%.d: %.cpp
	$(CC) -MM $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@

-include $(DEPS)

.cpp.o:
	${CC} ${CFLAGS} ${INCLUDES} -c $<

run: $(TARGET)
	./$(TARGET)
	@echo -----------------DONE-----------------
	@read -n 1

