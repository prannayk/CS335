CC=g++
CLANG=clang++
FLAGS=-lfl -std=c++17
FLAGC=-std=c++14 -stdlib=libstdc++ -ggdb3
BIN=bin/
TEST=tests/
# Lexer make [testing]

LEX_FOLDER=src/lex/
GEN_FOLDER=src/codegen/
BIN_GEN=bin/codegen/
BINLEX=bin/lex/
.PHONY: clean golang
test:
	flex -o ${LEX_FOLDER}test.yy.c ${LEX_FOLDER}test.l
	${CC} ${LEX_FOLDER}test.yy.c ${FLAGS} -o ${BINLEX}test.run
	${BINLEX}test.run ${TEST}start.txt

setup:
	mkdir -p bin
	mkdir -p bin/lex
	mkdir -p bin/codegen

golang:
	make setup
	bison --defines=${LEX_FOLDER}golang.tab.h ${LEX_FOLDER}golang.y -o ${LEX_FOLDER}golang.tab.c
	flex -o ${LEX_FOLDER}golang.yy.c ${LEX_FOLDER}golang.l
	${CC} ${LEX_FOLDER}golang.tab.c ${LEX_FOLDER}golang.yy.c ${FLAGS} -o ${BINLEX}golang.run
	for number in 1 2 3 4 5 6 ; do \
		echo "Testing with $$number.go"; \
		${BINLEX}golang.run ${TEST}$$number.go; \
	done

codegen:
	make setup
	bison --defines=${GEN_FOLDER}ir_lang.tab.h ${GEN_FOLDER}ir_lang.y -o ${GEN_FOLDER}ir_lang.tab.c
	flex --header-file=${GEN_FOLDER}ir_lang.yy.h -o ${GEN_FOLDER}ir_lang.yy.c ${GEN_FOLDER}ir_lang.l
	# ${CC} ${GEN_FOLDER}ir_lang.tab.c ${GEN_FOLDER}ir_lang.yy.c ${GEN_FOLDER}*.cpp ${FLAGS} -o ${BIN_GEN}ir_lang.run
	${CLANG}  ${GEN_FOLDER}*.cpp ${GEN_FOLDER}ir_lang.tab.c ${GEN_FOLDER}ir_lang.yy.c -stdlib=libstdc++  -lfl  -std=c++17 -ggdb3
	# ${CLANG} ${FLAGS} ${GEN_FOLDER}*.cpp ${GEN_FOLDER}*.c -o ${BIN_GEN}test.out

test_codegen:
	make codegen
	${BIN_GEN}test.out

clean:
	rm -r bin
	rm ${LEX_FOLDER}/golang.tab.*
	rm ${LEX_FOLDER}/golang.yy.c
