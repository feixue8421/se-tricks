SHELL = /bin/bash

GPP_VERSION = $(shell g++ -dumpversion)
ifeq ($(shell expr $(GPP_VERSION) '>=' 10.0), 1)
$(error g++ version requires 10.0 or newer version, current version: $(GPP_VERSION))
endif

CFLAGS = -Wall -g -std=c++20 -pthread
CC = g++
INCLUDES =
LIBS = -lm

TARGET = target.run.out

SOURCES = $(wildcard *.cpp)
OBJS = $(SOURCES:.cpp=.o)
DEPS = $(SOURCES:.cpp=.d)

.DEFAULT_GOAL := run

$(TARGET): $(DEPS) $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	-rm -f $(OBJS) $(DEPS) $(TARGET) 

%.d: %.cpp
	$(CC) -MM $(CFLAGS) $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@

-include $(DEPS)

.cpp.o:
	${CC} ${CFLAGS} ${INCLUDES} -c $<

run: $(TARGET)
	@echo -----------------BEGIN-----------------
	@./$(TARGET)
	@echo -----------------END-----------------
	@read -n 1

