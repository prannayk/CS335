print('''
%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
#define YYDEBUG 1
YY_DECL;
extern "C" int yyparse();
extern "C" FILE *yyin;
void yyerror(const char *s);
%}

%code requires {
    #include "Node.h"
}

%union {
    char* str;
    Node* nt;
};

%token   <str>          DEFAULT 1
%token   <str>          FUNC 2
%token   <str>          INTERFACE 3
%token   <str>          SELECT 4
%token   <str>          CASE 5
%token   <str>          DEFER 6
%token   <str>          GO 7
%token   <str>          MAP 8
%token   <str>          STRUCT 9
%token   <str>          CHAN 10
%token   <str>          ELSE 11
%token   <str>          GOTO 12
%token   <str>          PACKAGE 13
%token   <str>          SWITCH 14
%token   <str>          CONST 15
%token   <str>          FALLTHROUGH 16
%token   <str>          IF 17
%token   <str>          RANGE 18
%token   <str>          TYPE 19
%token   <str>          CONTINUE 20
%token   <str>          FOR 21
%token   <str>          IMPORT 22
%token   <str>          RETURN 23
%token   <str>          VAR 24
%token   <str>          NIL 25
%token   <str>          COMMENT_ST 26
%token   <str>          COMMENT_EN 27
%token   <str>          COMMENT_LN 28
%token   <str>          FOLDL 29
%token   <str>          FOLDR 30
%token   <str>          MMAP 31
%token   <str>          YIELD 32
%token   <str>          APPEND 33
%token   <str>          CAP 34
%token   <str>          CLOSE 35
%token   <str>          COPY 36
%token   <str>          DELETE 37
%token   <str>          LEN 38
%token   <str>          MAKE 39
%token   <str>          NEW 40
%token   <str>          PRINT 41
%token   <str>          PRINTLN 42
%token   <str>          GEN 43
%token   <str>          GENERIC_CONCAT 44
%token   <str>          GENERIC_NAME 45
%token   <str>          GENERIC_BNAME 46
%token   <str>          GENERIC_LIST 47
%token   <str>          NEWLINE 48
%token   <str>          UNICODE_CHAR 49
%token   <str>          UNICODE_LETTER 50
%token   <str>          LETTER 51
%token   <str>          DECIMAL_DIGIT 52
%token   <str>          OCTAL_DIGIT 53
%token   <str>          HEX_DIGIT 54
%token   <str>          ID 55
%token   <str>          DECIMAL_LIT 56
%token   <str>          OCTAL_LIT 57
%token   <str>          HEX_LIT 58
%token   <str>          INT_LIT 59
%token   <str>          DECIMALS 60
%token   <str>          EXP 61
%token   <str>          FLOAT_LIT 62
%token   <str>          OCTAL_BYTE 63
%token   <str>          HEX_BYTE 64
%token   <str>          BYTE_VAL 65
%token   <str>          ESCAPE 66
%token   <str>          RAW_STRING 67
%token   <str>          INTER_STRING 68
%token   <str>          STRING_LIT 69
%token   <str>          UINT8 70
%token   <str>          UINT16 71
%token   <str>          UINT32 72
%token   <str>          UINT64 73
%token   <str>          INT8 74
%token   <str>          INT16 75
%token   <str>          INT32 76
%token   <str>          INT64 77
%token   <str>          FLOAT32 78
%token   <str>          FLOAT64 79
%token   <str>          BYTE 80
%token   <str>          BOOL 81
%token   <str>          UINT 82
%token   <str>          INT 83
%token   <str>          UINTPTR 84
%token   <str>          OR 85
%token   <str>          AND 86
%token   <str>          LE 87
%token   <str>          LT 88
%token   <str>          GE 89
%token   <str>          GT 90
%token   <str>          EQ 91
%token   <str>          NE 92
%token   <str>          LS 93
%token   <str>          RS 94
%token   <str>          NOT_AND 95
%token   <str>          INC 96
%token   <str>          DEC 97
%token   <str>          DECL 98
%token   <str>          ADD 99
%token   <str>          SUB 100
%token   <str>          STAR 101
%token   <str>          DIV 102
%token   <str>          MOD 103
%token   <str>          BIT_OR 104
%token   <str>          BIT_AND 105
%token   <str>          CARET 106
%token   <str>          NOT_OP 107
%token   <str>          BIT_NOT 108
%token   <str>          PTR_OP 109
%token   <str>          AMPERSAND 110
%token   <str>          STMTEND 111
%token   <str>          TRUE 112
%token   <str>          FALSE 113
%token   <str>          REL_OP 114
%token   <str>          ADD_OP 115
%token   <str>          MUL_OP 116
%token   <str>          UNARY_OP 117
%token   <str>          BIN_OP 118
%token   <str>          VARIADIC 119
%token   <str>          ASSGN_OP 120
%token   <str>          PAREN_OPEN 121
%token   <str>          PAREN_CLOSE 122
%token   <str>          BLOCK_OPEN 123
%token   <str>          BLOCK_CLOSE 124
%token   <str>          DOT 125
%token   <str>          COMMA 126
%token   <str>          SQUARE_OPEN 127
%token   <str>          SQUARE_CLOSE 128
%token   <str>          BREAK 129
%token   <str>          COLON 130

''')
