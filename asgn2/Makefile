CC=clang++
FLAGCLANG=-stdlib=libstdc++ -lfl -std=c++14 -g
TEST=test
SRC=src
BIN=bin

.PHONY : clean setup codegen

codegen: setup
	bison --defines=${SRC}/ir_lang.tab.h ${SRC}/ir_lang.y -o ${SRC}/ir_lang.tab.c
	flex --header-file=${SRC}/ir_lang.yy.h -o ${SRC}/ir_lang.yy.c ${SRC}/ir_lang.l
	${CC}  ${SRC}/*.cpp ${SRC}/ir_lang.tab.c ${SRC}/ir_lang.yy.c ${FLAGCLANG} -o ${BIN}/codegen.run

clean:
	rm -r ${BIN}
setup:
	mkdir -p ${BIN}
