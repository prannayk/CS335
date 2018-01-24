/* Scanner / lexer for Golang */
%{
#include <math.h>
//#include <iostream>

//using namespace std;
extern "C" int yylex();
%}

DIGIT  [0-9]
ID  [a-zA-Z][a-zA-Z0-9_]*

%%

{DIGIT}+    {
            printf("An integer : %s (%d)\n", yytext, atoi(yytext));
            }
{DIGIT}+"."{DIGIT}*    {
            printf("An float : %s (%g)\n", yytext, atof(yytext));
            }
if|begin|end    {
            printf("An keyword : %s \n", yytext);
    }

{ID}        printf("An identifier: %s\n", yytext);

"+"|"-"|"*"

"{"[^}\n]*"}"

[ \t\n]+

.   printf("asd\n");

%% 

int main (int argc, char** argv)
{
    ++argv, --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else 
        yyin = stdin;
    yylex();
}
