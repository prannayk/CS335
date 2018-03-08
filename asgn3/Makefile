CC=g++
FLAGS=-lfl -std=c++14
TESTS=tests
BISON_FLAGS=-d

SRC=src
BIN=bin

.PHONY: all clean setup pogo lexer parser parser-defines

all: parser-pure pogo
	make render_one

setup:
	mkdir -p $(BIN)

clean:
	rm -r bin
	rm $(SRC)/golang.tab.*
	rm $(SRC)/golang.yy.c

parser-pure:
	cd $(SRC); \
	python3 ankit_bhardwaj.py > golang.y

parser parser-defines: parser-pure $(SRC)/golang.y
	cd $(SRC); \
	bison $(BISON_FLAGS) golang.y -v

lexer: parser-defines $(SRC)/golang.l
	cd $(SRC); \
	flex -o golang.yy.c golang.l

pogo: lexer parser setup
	$(CC) $(SRC)/Node.cpp $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(FLAGS) -o $(BIN)/executable

test: pogo
	for number in {1..1} ; do \
		echo "Testing with $$number.gop"; \
		$(BIN)/executable $(TESTS)/$$number.go; \
	done

render_one: 
	$(BIN)/executable $(TESTS)/1.gop 1> /dev/null 2> $(SRC)/display/data.js
