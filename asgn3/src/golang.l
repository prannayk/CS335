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
#define YY_DECL extern "C" int yylex()

#include "golang.tab.h"  // to get the token types that we return

/* extern "C" int yyparse(); */
/* extern "C" void yyerror(const char*); */
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
AS "::"

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
COLON ":"
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
SQ_PIPE_OPEN "[|"
SQ_PIPE_CLOSE "|]"
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
{COLON} { yylval.str = strdup(yytext);
          return COLON; }
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
{YIELD} { yylval.str = strdup(yytext);
          return YIELD; }
{VAR} { yylval.str = strdup(yytext);
          return VAR; }
{NIL} { yylval.str = strdup(yytext);
          return NIL; }
{AS} { yylval.str = strdup(yytext);
          return AS; }

{COMMENT_LN} { BEGIN(COMMENT); }

{GEN} { yylval.str = strdup(yytext);
          return GEN; }

{TRUE} { yylval.str = strdup(yytext);
          return TRUE; }
{FALSE} { yylval.str = strdup(yytext);
          return FALSE; }

{ID} { yylval.str = strdup(yytext);
          return ID; }

{GENERIC_CONCAT} { yylval.str = strdup(yytext);
          return GENERIC_CONCAT; }

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
{SQ_PIPE_OPEN} { yylval.str = strdup(yytext);
          return SQ_PIPE_OPEN; }
{SQ_PIPE_CLOSE} { yylval.str = strdup(yytext);
          return SQ_PIPE_CLOSE; }
{DOT} { yylval.str = strdup(yytext);
          return DOT; }
{COMMA} { yylval.str = strdup(yytext);
          return COMMA; }

<COMMENT>[\n] { BEGIN(INITIAL); }
<COMMENT>. /* ignore */
[ \t\n]+ /* removal of whitespace */

. printf("Do not understand symbol (%s)\n", yytext);
%%
