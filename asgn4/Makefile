CC=g++
FLAGS=-lfl -std=c++14 -g -O0
TESTS=tests
BISON_FLAGS=-d -Wall -v -Werror=conflicts-sr -Werror=conflicts-rr -g

SRC=src
BIN=bin

.PHONY: all clean setup pogo lexer parser parser-defines

all: pogo

setup:

clean:
	rm -r bin
	rm $(SRC)/golang.tab.*
	rm $(SRC)/golang.yy.c

parser-pure:
	cd $(SRC); \
	python3 ankit_bhardwaj.py > golang.y

$(SRC)/golang.tab.c: $(SRC)/golang.y
	cd $(SRC); \
	bison $(BISON_FLAGS) golang.y -v

$(SRC)/golang.yy.c: $(SRC)/golang.l $(SRC)/golang.tab.c
	cd $(SRC); \
	flex -o golang.yy.c golang.l

$(BIN)/parser: $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(SRC)/*.cpp $(SRC)/*.h $(SRC)/*.cc
	$(CC) $(SRC)/Node.cpp $(SRC)/golang.tab.c $(SRC)/golang.yy.c $(SRC)/helpers.cc $(SRC)/Type.cpp $(FLAGS) -o $(BIN)/parser

$(BIN):
	mkdir -p $(BIN)

pogo: $(BIN) $(BIN)/parser

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
