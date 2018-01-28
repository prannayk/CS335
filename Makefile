CC=g++
FLAGS=-lfl -std=c++17
BIN=bin/
TEST=tests/
# Lexer make [testing]

LEX_FOLDER=src/lex/
BINLEX=bin/lex/
test:
	flex -o ${LEX_FOLDER}test.yy.c ${LEX_FOLDER}test.l
	${CC} ${LEX_FOLDER}test.yy.c ${FLAGS} -o ${BINLEX}test.run
	${BINLEX}test.run ${TEST}start.txt

golang:
	bison --defines=${LEX_FOLDER}golang.tab.h ${LEX_FOLDER}golang.y -o ${LEX_FOLDER}golang.tab.c
	flex -o ${LEX_FOLDER}golang.yy.c ${LEX_FOLDER}golang.l
	${CC} ${LEX_FOLDER}golang.tab.c ${LEX_FOLDER}golang.yy.c ${FLAGS} -o ${BINLEX}golang.run
	for number in 1 2 3 4 5 6 ; do \
		${BINLEX}golang.run ${TEST}$$number.go; \
	done

