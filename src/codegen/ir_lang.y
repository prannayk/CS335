%{
#define yyerror atoi
extern "C" int yylex();
%}

%union {
    char* str;
};

%token <str> I8 1
%token <str> I16 2
%token <str> I32 3
%token <str> I64 4
%token <str> CHAR 5
%token <str> DEFINE 6
%token <str> GOTO_VAR 7
%token <str> CONSTANT 8
%token <str> FUNC_START 9
%token <str> FUNC_END 10
%token <str> CALL_VAR 11
%token <str> VAR 12 
%token <str> LABEL 13
%token <str> RETURN 14
%token <str> RELOP 15
%token <str> PRINT 16
%token <str> PTR 17
%token <str> ASSIGNMENT 18
%token <str> OPERATION 19
%token <str> OPIM 20
%token <str> UNMATCH 50
%token <str> GOTOSTMT 21
%token <str> FUNCTION_START 22

%%

expr:   I32
            ;

%%

