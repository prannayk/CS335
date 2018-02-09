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
#include<string.h>
#include"block.cpp"
#include"ir.cpp"
extern "C" int yylex();
#define YY_USER_ACTION ++ctr[yy_act]; 

#define NUM_TOKENS 130
using namespace std;
int ctr[YY_NUM_RULES];
vector<set<string>> counter (NUM_TOKENS);
vector<Instruction> i_list;
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
VNAME {LETTER}*[0-9]*
VAR \%{VNAME}
PTR ".ptr"
TYPE I8|I16|{I32}|I64|CHAR|PTR
DIGIT [0-9]
CONSTANT "$"{DIGIT}+
ARITHMETIC [+-/*]
SL "<<"
SR ">>"
GEQ ">="
LEQ "<="
GT ">"
LT "<"
EQ "=="
RELOP ({EQ}|{LT}|{GT}|{GEQ}|{LEQ})
OP ({ARITHMETIC}|{SR}|{SL}|{RELOP})
VAR_DECL ({VAR}" "*":"" "*{TYPE})
VAR_LIST ({VAR_DECL}(" "*","" "{VAR_DECL})*)
%x COMMENT
%%

{TYPE} { yylval.str = strdup(yytext); return I32;}
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*\n { yylval.str = strdup(yytext); return ASSIGNMENT; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{VAR} { yylval.str = strdup(yytext); return OPERATION; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{CONSTANT} { yylval.str = strdup(yytext); return OPIM; }
{GOTO}" "*{VAR}" "*{RELOP}" "*{VAR}" "*"\?"" "*{VNAME} { yylval.str = strdup(yytext); return GOTOSTMT; }
{DEFINE}" "*";"" "*{VNAME}" "*";"" "*{VAR_LIST}" "*";"" "*{TYPE}" "*"@" { yylval.str = strdup(yytext); return FUNCTION_START; }
\n { yylval.str = strdup(""); }
. {yylval.str = strdup(yytext); 
    return UNMATCH; }

%%

Type type_parse(char* type_var){
    Type type_code;
    switch(type_var[0]){
        case 'i' : type_code = INT; break;
    }
}

OpCode operation(char* operation){
            OpCode op;
            switch(operation[0]){
                case '+' : op = ADD; break;
                case '-' : op = SUB; break;
                case '*' : op = MUL; break;
                case '/' : op = DIV; break;
                case '>' : if(operation[1] == '>')  op = SR; else if(operation[1] == '=') op = GEQ; else op = GT; break;
                case '<' : if(operation[1] == '<')  op = SL; else if(operation[1] == '=') op = LEQ; else op = LT; break;
            }
            return op;
    
}

Instruction* operation(int imme){
            char* a;
            if(imme) a = strtok(yylval.str," :$%");
            else a = strtok(yylval.str," :%");
            int i = 0;
            char* target;
            char* op_string;
            char* arg1;
            char* arg2;
            char* type_var;
            while(a!=NULL){
                switch(i){
                    case 0 : 
                        target = strdup(a);
                    case 1 :
                        type_var = strdup(a); 
                    case 2 :
                        arg1 = strdup(a);
                    case 3 :
                        op_string = strdup(a);
                    case 4 :
                        arg2 = strdup(a);
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " ,=.:");
            }
            OpCode op = operation(op_string);
            Type type_code = type_parse(type_var);
            Instruction* new_inst;
            if(!imme) new_inst = new Instruction(op, target, arg1, arg2, REGISTER, REGISTER, REGISTER, type_code, type_code , type_code);
            else new_inst = new Instruction(op, target, arg1, arg2, REGISTER, REGISTER, CONSTANT_VAL, type_code, type_code , type_code);
            i_list.push_back(*new_inst);
            printf("OPERATION : %s %s %s %s %s\n", target, type_var, arg1, op_string, arg2);
}

void parse_goto(){
            char* a;
            a = strtok(yylval.str," :%?");
            int i = 0;
            char* branch;
            char* op_string;
            char* arg1;
            char* arg2;
            while(a!=NULL){
                switch(i){
                    case 0 : break; 
                    case 1 :
                        arg1 = strdup(a); break; 
                    case 2 :
                        op_string = strdup(a); break;
                    case 3 :
                        arg2 = strdup(a); break;
                    case 4 :
                        branch = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " :?%");
            }
    OpCode op = operation(op_string);
    OpCode gotoop;
    switch (op) {
        case EQ : gotoop = GOTOEQ; break; 
        case LT : gotoop = GOTOLT; break; 
        case GT : gotoop = GOTOGT; break; 
        case GEQ: gotoop = GOTOGEQ; break; 
        case LEQ: gotoop = GOTOLEQ; break; 
        case NEQ: gotoop = GOTONEQ; break; 
    }
    Instruction* new_inst;
    new_inst = new Instruction(op, arg1, arg2, branch, CONSTANT_VAL, REGISTER, REGISTER, INT , INT, BRANCH);
    i_list.push_back(*new_inst);
}

int num_args(char* arg_list){
            int i = 0;
            char* a;
            a = strtok(arg_list," ,");
            while(a!=NULL){
                i++;
                a = strtok(NULL, " ,");
            }
            return i;
}

void push_args(char * arg_list){
    char * a;
    a = strtok(arg_list, " ,.");
    do {
       Instruction *new_inst;
       new_inst = new Instruction(PDECL_OP, strdup(a), CONSTANT_VAL, STRING);
       i_list.push_back(*new_inst);
    } while((a = strtok(NULL, " ,.")) != NULL);
}

void parse_function(){ // function to parse the start of function
            char* a;
            a = strtok(yylval.str,";");
            int i = 0;
            char* name;
            char* arg_list;
            char* rtype;
            while(a!=NULL){
                switch(i){
                    case 0 : break; 
                    case 1 :
                        name = strdup(a); break; 
                    case 2 :
                        arg_list = strdup(a); break;
                    case 3 :
                        rtype = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " ;");
            }
    int* num ; 
    num = new int;
    *num = num_args(arg_list);
    Instruction* new_inst;
    /* new_inst = new Instruction(op, arg1, arg2, branch, CONSTANT_VAL, REGISTER, REGISTER, INT , INT, BRANCH); */
    new_inst = new Instruction(FUNC_OP, name, rtype, num,CONSTANT_VAL, CONSTANT_VAL, CONSTANT_VAL, STRING, STRING, INT );
    i_list.push_back(*new_inst);
    push_args(arg_list);
}

int main (int argc, char** argv)
{
    ++argv, --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    while(1){
        int k = yylex();
        if(!k) break;
        else
            switch(k){
                case OPERATION : operation(0); break;
                case OPIM : operation(1); break;
                case GOTOSTMT : parse_goto(); break;
                case FUNCTION_START : parse_function(); break;
            }
        counter[k].insert(strdup(yylval.str)); 
    }
    IR ir(i_list);
}
