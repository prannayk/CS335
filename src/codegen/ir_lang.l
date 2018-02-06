/* Scanner / lexer for IR */
%{
#include <math.h>
#include "ir_lang.tab.h"
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <iomanip>
#include <set>
#include <vector>
extern "C" int yylex();
#define YY_USER_ACTION ++ctr[yy_act]; 

#define NUM_TOKENS 130
using namespace std;
int ctr[YY_NUM_RULES];
vector<set<string>> counter (NUM_TOKENS);
%}

/* start define keywords */
DEFINE ".define"
CALL ".call"
LABEL ".label"
I8 ".i8"
I16 ".i16"
I32 ".i32"
I64 ".i64"
CHAR ".char"
GOTO "goto"
LETTER [a-zA-Z]
VAR \%{LETTER}*[0-9]*
PTR ".ptr"
TYPE I8|I16|{I32}|I64|CHAR|PTR
DIGIT [0-9]
CONSTANT "$"{DIGIT}+
ARITHMETIC [+-/*]
SL "<"
SR ">"
OP {ARITHMETIC}|{SR}|{SL}
%x COMMENT
%%

{TYPE} { yylval.str = strdup(yytext); return I32;}

{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*\n { yylval.str = strdup(yytext); return ASSIGNMENT; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{VAR} { yylval.str = strdup(yytext); return OPERATION; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{CONSTANT} { yylval.str = strdup(yytext); return OPIM; }
\n { yylval.str = strdup(""); }
. {yylval.str = strdup(yytext); 
    return UNMATCH; }

%%

int main (int argc, char** argv)
{
    ++argv, --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    while(1){
        int k = yylex();
        if(k == 0) break;
        printf("H : %s\t\t%d\n", yylval.str, k);
        counter[k].insert(strdup(yylval.str)); 
    }
}
