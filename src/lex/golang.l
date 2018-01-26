/* Scanner / lexer for Golang */
%{
#include <math.h>
#include "golang.tab.h"
extern "C" int yylex();
%}

/* start define keywords */

BREAK break
DEFAULT default
FUNC func
INTERFACE interface
SELECT select
CASE case
DEFER defer
GO go
MAP map
STRUCT struct
CHAN chan
ELSE else
GOTO goto
PACKAGE package
SWITCH switch
CONST const
FALLTHROUGH fallthrough
IF if
RANGE range
TYPE type
CONTINUE continue
FOR for
IMPORT import
RETURN return
VAR var
NIL nil

COMMENT_ST "/*"
COMMENT_EN "*/"
COMMENT_LN "//"

FOLDL FoldL
FOLDR FoldR
MMAP MMap
YIELD yield
APPEND  append
CAP  cap
CLOSE  close
COPY  copy
DELETE  delete
LEN len
MAKE  make
NEW  new
PRINT  print
PRINTLN  println
GEN gen

GENERIC_CONCAT "$"
GENERIC_NAME {ID}
GENERIC_BNAME {GENERIC_NAME}(":"{ID}("$"{ID})+)?
GENERIC_LIST "<"({GENERIC_BLIST}(","{GENERIC_BLIST})*)">"

/* end define keywords */

/* entering numbers, unicode etc */

NEWLINE [\n]
UNICODE_CHAR [^\n]
UNICODE_LETTER [a-zA-Z]
LETTER ({UNICODE_LETTER}|_)

DECIMAL_DIGIT [0-9]
OCTAL_DIGIT [0-7]
HEX_DIGIT [0-9A-Fa-f]

ID {LETTER}({LETTER}|{DECIMAL_DIGIT})*

DECIMAL_LIT (0|[1-9]{DECIMAL_DIGIT}*)
OCTAL_LIT 0[OCTAL_DIGIT]+
HEX_LIT 0[xX]{HEX_DIGIT}+

INT_LIT ({DECIMAL_LIT}|{OCTAL_LIT}|{HEX_LIT})


DECIMALS {DECIMAL_DIGIT}+
EXP [eE][+-]{DECIMALS}

FLOAT_LIT (({DECIMALS}"."{DECIMALS}?{EXP}?)|({DECIMALS}{EXP})|("."{DECIMALS}{EXP}?))

OCTAL_BYTE \\({OCTAL_DIGIT}{3})
HEX_BYTE \\"x"{HEX_DIGIT}{2}
BYTE_VAL ({OCTAL_BYTE}|{HEX_BYTE})
ESCAPE \\[nr\\t\'\"\`]

RAW_STRING \`([\`]|{ESCAPE})*\`
INTER_STRING \"([^\n\"]|{BYTE_VAL}|{ESCAPE})*\"
STRING_LIT ({INTER_STRING}|{RAW_STRING})

UINT8 uint8
UINT16 uint16
UINT32 uint32
UINT64 uint64
INT8 int8
INT16 int16
INT32 int32
INT64 int64
FLOAT32 float32
FLOAT64 float64
BYTE byte
BOOL bool
UINT uint
INT int
UINTPTR uintptr

OR "\|\|"
AND "&&"
LE "<="
LT "<"
GE ">="
GT ">"
EQ "=="
NE "!="
LS "<<"
RS ">>"
NOT_AND "&^"
INC "++"
DEC "--"
DECL ":="
ADD "+"
SUB "-"
MUL "*"
DIV "/"
MOD "%"
BIT_OR "|"
BIT_AND "&"
EXP_OP "^"
NOT_OP "!"
BIT_NOT "^"
PTR_OP "*"
REF_OP "&"
STMTEND ";"

TRUE true
FALSE false

REL_OP  {EQ}|{NE}|{GE}|{GT}|{LE}|{LT}
ADD_OP {ADD}|{SUB}|{BIT_OR}|{EXP_OP}
MUL_OP {MUL}|{DIV}|{MOD}|{LS}|{RS}|{BIT_AND}|{AO}
UNARY_OP {ADD_OP}|{SUB_OP}|{NOT_OP}|{BIT_NOT}|{PTR_OP}|{REF_OP}
BIN_OP {OR}|{AND}|{REL_OP}|{ADD_OP}|{MUL_OP}

VARIADIC "..."
ASSGN_OP ({ADD_OP}|{MUL_OP})?"="

PAREN_OPEN "("
PAREN_CLOSE ")"
BLOCK_OPEN "{"
BLOCK_CLOSE "}"
DOT "."

%%

{OCTAL_BYTE} {
    printf("Octal digit recognized : %s\n", yytext);
    yylval.str = strdup(yytext);
    return OCTAL_BYTE;
}
{HEX_BYTE} {
    printf("Hexadecimal digit recognized : %s\n", yytext);
}


[ \t\n]+ /* removal of whitespace */

. printf("Do not understand symbol");
%%

int main (int argc, char** argv)
{
    ++argv, --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    int k = yylex();
    printf("%d\n", k == OCTAL_BYTE);
    printf("%s", yylval.str);
}
