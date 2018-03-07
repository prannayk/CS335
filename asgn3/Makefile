CC=g++
FLAGS=-lfl -std=c++14
BIN=bin/
TEST=test/

SRC=src
BIN=bin

.PHONY: all clean setup pogo lexer parser parser-defines

all: pogo

setup:
	mkdir -p $(BIN)

clean:
	rm -r bin
	rm $(SRC)/golang.tab.*
	rm $(SRC)/golang.yy.c

parser parser-defines: $(SRC)/golang.y
	cd $(SRC); \
	bison -d golang.y

lexer: parser-defines $(SRC)/golang.l
	cd $(SRC); \
	flex -o golang.yy.c golang.l

pogo: lexer parser setup
	$(CC) $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(FLAGS) -o $(BIN)/executable
