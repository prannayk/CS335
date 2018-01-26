CC=g++
FLAGS=-lfl
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
	bison -d ${LEX_FOLDER}golang.yy
	flex -o ${LEX_FOLDER}golang.yy.c ${LEX_FOLDER}golang.l
	${CC} ${LEX_FOLDER}golang.yy.c ${FLAGS} -o ${BINLEX}golang.run
	${BINLEX}golang.run ${TEST}start.txt

