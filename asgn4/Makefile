CC=g++
FLAGS=-lfl -std=c++14
TESTS=tests
BISON_FLAGS=-d -Wall -v -Werror=conflicts-sr -Werror=conflicts-rr

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
	cd $(SRC); \
	python3 ankit_bhardwaj.py > golang.y

parser parser-defines: $(SRC)/golang.y
	cd $(SRC); \
	bison $(BISON_FLAGS) golang.y -v

lexer: parser-defines $(SRC)/golang.l
	cd $(SRC); \
	flex -o golang.yy.c golang.l

pogo: lexer parser setup
	$(CC) $(SRC)/Node.cpp $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(FLAGS) -o $(BIN)/parser

test: pogo
	for number in {1..10} ; do \
		echo "Testing with $$number.gop"; \
		./prepare.sh $(TESTS)/$$number.gop /tmp/$$number.gop;  \
		$(BIN)/parser /tmp/$$number.gop 1> /dev/null 2> $(SRC)/display/data$$number.js; \
	done

render:
	./prepare.sh $(TESTS)/$(FNUM).gop /tmp/1.gop;  \
	$(BIN)/parser /tmp/1.gop 1> /dev/null 2> $(SRC)/display/data$(FNUM).js;

render_one:
	./prepare.sh $(TESTS)/$(FNUM).gop /tmp/1.gop; \
	$(BIN)/parser /tmp/1.gop 2> $(SRC)/display/flare.js;
