/* Scanner / lexer for Golang */
%{
#include <math.h>
#include "golang.tab.h"
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
GENERIC_BNAME [ \t]*{ID}[ \t]*
GENERIC_BLIST {GENERIC_BNAME}([ \t]*"$"[ \t]*({GENERIC_BNAME}))*
GENERIC_BTYPE {ID}[ \t]*(:[ \t]*{GENERIC_BLIST}[ \t]*)?
GENERIC_LIST "<"[ \t]*{GENERIC_BTYPE}([ \t]*,[ \t]*{GENERIC_BTYPE}[ \t]*)*[ \t]*">"
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

RAW_STRING \`([^\`]|{ESCAPE})*\`
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
STAR "*"
DIV "/"
MOD "%"
BIT_OR "|"
AMPERSAND "&"
CARET "^"
NOT_OP "!"
STMTEND ";"

TRUE true
FALSE false

REL_OP  {EQ}|{NE}|{GE}|{GT}|{LE}|{LT}
ADD_OP {ADD}|{SUB}|{BIT_OR}|{CARET}
MUL_OP {STAR}|{DIV}|{MOD}|{LS}|{RS}|{AMPERSAND}|{NOT_AND}
UNARY_OP {ADD}|{SUB}|{NOT_OP}|{CARET}|{STAR}|{AMPERSAND}
BIN_OP {OR}|{AND}|{REL_OP}|{ADD_OP}|{MUL_OP}

VARIADIC "..."
ASSGN_OP ({ADD_OP}|{MUL_OP})?"="

PAREN_OPEN "("
PAREN_CLOSE ")"
BLOCK_OPEN "{"
BLOCK_CLOSE "}"
DOT "."
COMMA ","

SQUARE_OPEN "["
SQUARE_CLOSE "]"

%x COMMENT
%%
{BREAK} { yylval.str = strdup(yytext);
          return BREAK; }
{DEFAULT} { yylval.str = strdup(yytext);
          return DEFAULT; }
{FUNC} { yylval.str = strdup(yytext);
          return FUNC; }
{INTERFACE} { yylval.str = strdup(yytext);
          return INTERFACE; }
{SELECT} { yylval.str = strdup(yytext);
          return SELECT; }
{CASE} { yylval.str = strdup(yytext);
          return CASE; }
{DEFER} { yylval.str = strdup(yytext);
          return DEFER; }
{GO} { yylval.str = strdup(yytext);
          return GO; }
{MAP} { yylval.str = strdup(yytext);
          return MAP; }
{STRUCT} { yylval.str = strdup(yytext);
          return STRUCT; }
{CHAN} { yylval.str = strdup(yytext);
          return CHAN; }
{ELSE} { yylval.str = strdup(yytext);
          return ELSE; }
{GOTO} { yylval.str = strdup(yytext);
          return GOTO; }
{PACKAGE} { yylval.str = strdup(yytext);
          return PACKAGE; }
{SWITCH} { yylval.str = strdup(yytext);
          return SWITCH; }
{CONST} { yylval.str = strdup(yytext);
          return CONST; }
{FALLTHROUGH} { yylval.str = strdup(yytext);
          return FALLTHROUGH; }
{IF} { yylval.str = strdup(yytext);
          return IF; }
{RANGE} { yylval.str = strdup(yytext);
          return RANGE; }
{TYPE} { yylval.str = strdup(yytext);
          return TYPE; }
{CONTINUE} { yylval.str = strdup(yytext);
          return CONTINUE; }
{FOR} { yylval.str = strdup(yytext);
          return FOR; }
{IMPORT} { yylval.str = strdup(yytext);
          return IMPORT; }
{RETURN} { yylval.str = strdup(yytext);
          return RETURN; }
{VAR} { yylval.str = strdup(yytext);
          return VAR; }
{NIL} { yylval.str = strdup(yytext);
          return NIL; }

{COMMENT_LN} { BEGIN(COMMENT); }

{FOLDL} { yylval.str = strdup(yytext);
          return FOLDL; }
{FOLDR} { yylval.str = strdup(yytext);
          return FOLDR; }
{MMAP} { yylval.str = strdup(yytext);
          return MMAP; }
{YIELD} { yylval.str = strdup(yytext);
          return YIELD; }
{APPEND} { yylval.str = strdup(yytext);
          return APPEND; }
{CAP} { yylval.str = strdup(yytext);
          return CAP; }
{CLOSE} { yylval.str = strdup(yytext);
          return CLOSE; }
{COPY} { yylval.str = strdup(yytext);
          return COPY; }
{DELETE} { yylval.str = strdup(yytext);
          return DELETE; }
{LEN} { yylval.str = strdup(yytext);
          return LEN; }
{MAKE} { yylval.str = strdup(yytext);
          return MAKE; }
{NEW} { yylval.str = strdup(yytext);
          return NEW; }
{PRINT} { yylval.str = strdup(yytext);
          return PRINT; }
{PRINTLN} { yylval.str = strdup(yytext);
          return PRINTLN; }
{GEN} { yylval.str = strdup(yytext);
          return GEN; }

{UINT8} { yylval.str = strdup(yytext);
          return UINT8; }
{UINT16} { yylval.str = strdup(yytext);
          return UINT16; }
{UINT32} { yylval.str = strdup(yytext);
          return UINT32; }
{UINT64} { yylval.str = strdup(yytext);
          return UINT64; }
{INT8} { yylval.str = strdup(yytext);
          return INT8; }
{INT16} { yylval.str = strdup(yytext);
          return INT16; }
{INT32} { yylval.str = strdup(yytext);
          return INT32; }
{INT64} { yylval.str = strdup(yytext);
          return INT64; }
{FLOAT32} { yylval.str = strdup(yytext);
          return FLOAT32; }
{FLOAT64} { yylval.str = strdup(yytext);
          return FLOAT64; }
{BYTE} { yylval.str = strdup(yytext);
          return BYTE; }
{BOOL} { yylval.str = strdup(yytext);
          return BOOL; }
{UINT} { yylval.str = strdup(yytext);
          return UINT; }
{INT} { yylval.str = strdup(yytext);
          return INT; }
{UINTPTR} { yylval.str = strdup(yytext);
          return UINTPTR; }

{TRUE} { yylval.str = strdup(yytext);
          return TRUE; }
{FALSE} { yylval.str = strdup(yytext);
          return FALSE; }

{ID} { yylval.str = strdup(yytext);
          return ID; }

{GENERIC_LIST} { yylval.str = strdup(yytext);
          return GENERIC_LIST; }

{HEX_LIT} { yylval.str = strdup(yytext);
          return HEX_LIT; }
{OCTAL_LIT} { yylval.str = strdup(yytext);
          return OCTAL_LIT; }
{DECIMAL_LIT} { yylval.str = strdup(yytext);
          return DECIMAL_LIT; }

{FLOAT_LIT} { yylval.str = strdup(yytext);
          return FLOAT_LIT; }

{OCTAL_BYTE} { yylval.str = strdup(yytext);
          return OCTAL_BYTE; }
{HEX_BYTE} { yylval.str = strdup(yytext);
          return HEX_BYTE; }
{ESCAPE} { yylval.str = strdup(yytext);
          return ESCAPE; }

{RAW_STRING} { yylval.str = strdup(yytext);
          return RAW_STRING; }
{INTER_STRING} { yylval.str = strdup(yytext);
          return INTER_STRING; }

{OR} { yylval.str = strdup(yytext);
          return OR; }
{AND} { yylval.str = strdup(yytext);
          return AND; }
{LE} { yylval.str = strdup(yytext);
          return LE; }
{LT} { yylval.str = strdup(yytext);
          return LT; }
{GE} { yylval.str = strdup(yytext);
          return GE; }
{GT} { yylval.str = strdup(yytext);
          return GT; }
{EQ} { yylval.str = strdup(yytext);
          return EQ; }
{NE} { yylval.str = strdup(yytext);
          return NE; }
{LS} { yylval.str = strdup(yytext);
          return LS; }
{RS} { yylval.str = strdup(yytext);
          return RS; }
{NOT_AND} { yylval.str = strdup(yytext);
          return NOT_AND; }
{INC} { yylval.str = strdup(yytext);
          return INC; }
{DEC} { yylval.str = strdup(yytext);
          return DEC; }
{DECL} { yylval.str = strdup(yytext);
          return DECL; }
{ADD} { yylval.str = strdup(yytext);
          return ADD; }
{SUB} { yylval.str = strdup(yytext);
          return SUB; }
{STAR} { yylval.str = strdup(yytext);
          return STAR; }
{DIV} { yylval.str = strdup(yytext);
          return DIV; }
{MOD} { yylval.str = strdup(yytext);
          return MOD; }
{BIT_OR} { yylval.str = strdup(yytext);
          return BIT_OR; }
{AMPERSAND} { yylval.str = strdup(yytext);
          return AMPERSAND; }
{CARET} { yylval.str = strdup(yytext);
          return CARET; }
{NOT_OP} { yylval.str = strdup(yytext);
          return NOT_OP; }
{STMTEND} { yylval.str = strdup(yytext);
          return STMTEND; }



{VARIADIC} { yylval.str = strdup(yytext);
          return VARIADIC; }
{ASSGN_OP} { yylval.str = strdup(yytext);
          return ASSGN_OP; }

{PAREN_OPEN} { yylval.str = strdup(yytext);
          return PAREN_OPEN; }
{PAREN_CLOSE} { yylval.str = strdup(yytext);
          return PAREN_CLOSE; }
{BLOCK_OPEN} { yylval.str = strdup(yytext);
          return BLOCK_OPEN; }
{BLOCK_CLOSE} { yylval.str = strdup(yytext);
          return BLOCK_CLOSE; }
{SQUARE_OPEN} { yylval.str = strdup(yytext);
          return SQUARE_OPEN; }
{SQUARE_CLOSE} { yylval.str = strdup(yytext);
          return SQUARE_CLOSE; }
{DOT} { yylval.str = strdup(yytext);
          return DOT; }
{COMMA} { yylval.str = strdup(yytext);
          return COMMA; }

<COMMENT>[\n] { BEGIN(INITIAL); }
<COMMENT>. /* ignore */
[ \t\n]+ /* removal of whitespace */

. printf("Do not understand symbol (%s)\n", yytext);
%%

const char* tokens[] = {"PADDING", "DEFAULT", "FUNC", "INTERFACE", "SELECT", "CASE", "DEFER", "GO", "MAP", "STRUCT", "CHAN", "ELSE", "GOTO", "PACKAGE", "SWITCH", "CONST", "FALLTHROUGH", "IF", "RANGE", "TYPE", "CONTINUE", "FOR", "IMPORT", "RETURN", "VAR", "NIL", "COMMENT_ST", "COMMENT_EN", "COMMENT_LN", "FOLDL", "FOLDR", "MMAP", "YIELD", "APPEND", "CAP", "CLOSE", "COPY", "DELETE", "LEN", "MAKE", "NEW", "PRINT", "PRINTLN", "GEN", "GENERIC_CONCAT", "GENERIC_NAME", "GENERIC_BNAME", "GENERIC_LIST", "NEWLINE", "UNICODE_CHAR", "UNICODE_LETTER", "LETTER", "DECIMAL_DIGIT", "OCTAL_DIGIT", "HEX_DIGIT", "ID", "DECIMAL_LIT", "OCTAL_LIT", "HEX_LIT", "INT_LIT", "DECIMALS", "EXP", "FLOAT_LIT", "OCTAL_BYTE", "HEX_BYTE", "BYTE_VAL", "ESCAPE", "RAW_STRING", "INTER_STRING", "STRING_LIT", "UINT8", "UINT16", "UINT32", "UINT64", "INT8", "INT16", "INT32", "INT64", "FLOAT32", "FLOAT64", "BYTE", "BOOL", "UINT", "INT", "UINTPTR", "OR", "AND", "LE", "LT", "GE", "GT", "EQ", "NE", "LS", "RS", "NOT_AND", "INC", "DEC", "DECL", "ADD", "SUB", "STAR", "DIV", "MOD", "BIT_OR", "BIT_AND", "CARET", "NOT_OP", "BIT_NOT", "PTR_OP", "AMPERSAND", "STMTEND", "TRUE", "FALSE", "REL_OP", "ADD_OP", "MUL_OP", "UNARY_OP", "BIN_OP", "VARIADIC", "ASSGN_OP", "PAREN_OPEN", "PAREN_CLOSE", "BLOCK_OPEN", "BLOCK_CLOSE", "DOT", "COMMA", "SQUARE_OPEN", "SQUARE_CLOSE", "BREAK"};

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
        // printf("%s\t\t%s\t\t%d\n", tokens[k], yylval.str, k);
        counter[k].insert(strdup(yylval.str)); 
    }
    int po, tempcount;
    cout << left
         << setfill(' ')
         << setw(20)
         << "Tokens"
         << left
         << setfill(' ')
         << setw(20)
         << "Occurances"
         << left
         << setfill(' ')
         << setw(20)
         << "Lexemes"
         << endl;
    for (po = 1; po < NUM_TOKENS; po++) {
        if(counter[po].size() > 0) {
            tempcount = counter[po].size();
            set<string>::iterator it = counter[po].begin();
            cout << left
                 << setfill(' ')
                 << setw(20)
                 << tokens[po]
                 << left
                 << setfill(' ')
                 << setw(20)
                 << counter[po].size()
                 << (*it)
                 << endl;
            while(tempcount > 1) {
                 it++;
                 tempcount--;
                 cout << string(40, ' ')
                      << (*it)
                      <<endl;
                 
            }
        }

    }
}
