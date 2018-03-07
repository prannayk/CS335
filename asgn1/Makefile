CC=g++
FLAGS=-lfl -std=c++17
BIN=bin/
TEST=test/
# Lexer make [testing]

LEX_FOLDER=src/
BINLEX=bin/
.PHONY: clean golang setup test

golang:
	make setup
	bison --defines=${LEX_FOLDER}golang.tab.h ${LEX_FOLDER}golang.y -o ${LEX_FOLDER}golang.tab.c
	flex -o ${LEX_FOLDER}golang.yy.c ${LEX_FOLDER}golang.l
	${CC} ${LEX_FOLDER}golang.tab.c ${LEX_FOLDER}golang.yy.c ${FLAGS} -o ${BINLEX}lexer

setup:
	mkdir -p ${BINLEX}

test:
	for number in 1 2 3 4 5 6 ; do \
		echo "Testing with $$number.go"; \
		${BINLEX}lexer ${TEST}$$number.go; \
	done
clean:
	rm -r bin
	rm ${LEX_FOLDER}golang.tab.*
	rm ${LEX_FOLDER}golang.yy.c
