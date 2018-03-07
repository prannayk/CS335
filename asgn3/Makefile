CC=g++
FLAGS=-lfl -std=c++14
TEST=test
BISON_FLAGS=-d -Wconflicts-sr

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

parser-pure:
	python3 $(SRC)/ankit_bhardwaj.py > $(SRC)/golang.y

parser parser-defines: parser-pure $(SRC)/golang.y
	cd $(SRC); \
	bison $(BISON_FLAGS) golang.y -v

lexer: parser-defines $(SRC)/golang.l
	cd $(SRC); \
	flex -o golang.yy.c golang.l

pogo: lexer parser setup
	$(CC) $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(FLAGS) -o $(BIN)/executable
