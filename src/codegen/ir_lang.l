/* Scanner / lexer for IR */
%{
#pragma once

#include <math.h>
#include "ir_lang.tab.h"
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <iomanip>
#include <set>
#include <vector>
#include<string.h>


#include"block.h"
#include"ir.h"
extern "C" int yylex();
#define YY_USER_ACTION ++ctr[yy_act]; 

#define NUM_TOKENS 130
using namespace std;
int ctr[YY_NUM_RULES];
vector<set<string>> counter (NUM_TOKENS);
vector<Instruction> i_list;
SymbolTable symtab;
%}

/* start define keywords */
DEFINE ".define"
CALL "call"
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
TYPE ({I8}|{I16}|{I32}|{I64}|{CHAR}|{PTR})
DIGIT [0-9]
CONSTANT "$"{DIGIT}+
ASHR "ashr"
AND "&"
OR "|"
XOR "^"
MOD "mod"
SL "<<"
SR ">>"
BITHMETIC [+-/*]
ARITHMETIC ({BITHMETIC}|{MOD}|{ASHR}|{AND}|{OR}|{XOR})
GEQ ">="
LEQ "<="
GT ">"
LT "<"
EQ "=="
NOT "~"
NEG "-"
LNOT "lnot"
UNOP ({NOT}|{NEG}|{LNOT})
RELOP ({EQ}|{LT}|{GT}|{GEQ}|{LEQ})
OP ({ARITHMETIC}|{SR}|{SL}|{RELOP})
VAR_DECL ({TYPE})
VAR_LIST ({VAR_DECL}(" "*","" "{VAR_DECL})*)
F_END "!"
RET "ret"
FPTR "followptr"
GADDR "gettaddr"
PINT "printint"
%x COMMENT
%%

{LABEL}" "*{VNAME} { yylval.str = strdup(yytext); return LABELSTMT; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*\n { yylval.str = strdup(yytext); return ASSIGNMENT; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{VAR} { yylval.str = strdup(yytext); return OPERATION; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{VAR}" "*{OP}" "*{CONSTANT} { yylval.str = strdup(yytext); return OPIM; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{CONSTANT}" "*{OP}" "*{VAR} { yylval.str = strdup(yytext); return OPIM; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{CONSTANT}" "*{OP}" "*{CONSTANT} { yylval.str = strdup(yytext); return OPIM; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*({VAR}|{CONSTANT}) { yylval.str = strdup(yytext); return UN_ASSIGNMENT; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{UNOP}" "*({VAR}|{CONSTANT}) { yylval.str = strdup(yytext); return UN_OP; }
{GOTO}" "*({VAR}|{CONSTANT})" "*{RELOP}" "*({VAR}|{CONSTANT})" "*"\?"" "*{VNAME} { yylval.str = strdup(yytext); return GOTOSTMT; }
{GOTO}" "*{VNAME} { yylval.str = strdup(yytext); return GOTO; }
{DEFINE}" "*";"" "*{VNAME}" "*";"" "*{VAR_LIST}" "*";"" "*{TYPE}" "*"@" { yylval.str = strdup(yytext); return FUNCTION_START; }
{CALL}" "*{VNAME} { yylval.str = strdup(yytext); return CALL_FN; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{CALL}" "*{VNAME} { yylval.str = strdup(yytext); return CALL_FN_RET; }
{VAR}" "*":"" "*{TYPE}" "*"="" "*{FPTR}" "*{VAR} { yylval.str = strdup(yytext); return FPTR; }
{VAR}" "*":"" "*{PTR}" "*"="" "*{GADDR}" "*{VAR}" "*":"" "*{TYPE}  { yylval.str = strdup(yytext); return GADDR; }
{RET}" "*{VAR} { yylval.str = strdup(yytext); return RETURN; }
{F_END} { yylval.str = strdup(yytext); return FUNCTION_END; }
{PINT}" "*{VAR} { yylval.str = strdup(yytext); return PINT;  }
\n { yylval.str = strdup(""); }
. {yylval.str = strdup(yytext); 
    return UNMATCH; }

%%

int getNum(char* entry){
    char *cpy = entry;
    while(*cpy != '\0') if(((*cpy <= 'z' && *cpy >= 'a') || (*cpy <= 'Z' && *cpy>='A')))    cpy++; else break;
    return atoi(cpy);
}

AddressingMode getMode(char* entry){
    if(entry[0] == '$') return CONSTANT_VAL;
    return REGISTER;
}

void* getConst(char* entry, Type type_val){
    if (type_val == INT){
        int * ptr = new int;
        *ptr = atoi(entry);
        return ptr;
    }
    return NULL;
}

void* getEntry(char* entry, Type type_val){
    if(entry[0] == '$') return getConst(entry, type_val);
    int i=0; char st;
    for(i=0;entry[i]!='\0';i++) if(!((entry[i] <= 'z' && entry[i] >= 'a') || (entry[i] <= 'Z' && entry[i]>='A')))   { st = entry[i]; entry[i] = '\0'; break;}
    if(symtab.checkEntry(entry)){
        SymbolTableEntry * newEntry ; 
        newEntry = new SymbolTableEntry(entry, type_val);
        symtab.addEntry(newEntry);
        entry[i] = st;
        return newEntry;
    }
    SymbolTableEntry* a = symtab.getEntry(entry);
    entry[i] = st;
    return a;
}


Type type_parse(char* type_var){
    Type type_code;
    switch(type_var[0]){
        case 'i' : type_code = INT; break;
        case 'p' : type_code = PTR; break;
    }
    return type_code;
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
                case 'm' : op = MOD;  break;
                case '&' : op = AND; break;
                case '|' : op = OR; break;
                case '^' : op = XOR; break;
                case '=' : if(operation[1] == '=')  op = EQ; break;
            }
            return op;
    
}

OpCode unary_op(char* op_string){
    switch(op_string[0]){
        case '-' : return NEG;
        case '~' : return NOT;
        case 'l' : return LNOT;
    }
    return NULL_IST;
}

void unary_op(int flag){
            char* a;
            a = strtok(yylval.str," :%,=.");
            int i = 0;
            char* target;
            char* op_string;
            char* arg1;
            char* arg2;
            char* type_var;
            while(a!=NULL){
                switch(i){
                    case 0 : 
                        target = strdup(a); break;
                    case 1 :
                        type_var = strdup(a); break; 
                    case 2 :
                        if(!flag)    op_string = strdup(a); else arg1 = strdup(a); break;
                    case 3 :
                        arg1 = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " ,=.:%");
            }
            Type type_code = type_parse(type_var);
            Instruction* new_inst;
            OpCode op;
            if(!flag) op = unary_op(op_string); else op = ASG;
            new_inst = new Instruction(op, getEntry(target, type_code), getEntry(arg1, type_code), getMode(target), getMode(arg1), type_code, type_code, getNum(target), getNum(arg1));
            i_list.push_back(*new_inst); return;
    
}

void operation(int imme){
            char* a;
            if(imme) a = strtok(yylval.str," :%");
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
                a = strtok(NULL, " ,=.:%");
            }
            Type type_code = type_parse(type_var);
            if(imme == 2)   {
                Instruction* new_inst;
                OpCode op = unary_op(op_string);
                new_inst = new Instruction(op, getEntry(target, type_code), getEntry(arg1, type_code), getMode(target), getMode(arg1), type_code, type_code, getNum(target), getNum(arg1));
                i_list.push_back(*new_inst); return;
            }
            OpCode op = operation(op_string);
            Instruction* new_inst;
            new_inst = new Instruction(op, getEntry(target, type_code), getEntry(arg1, type_code), getEntry(arg2, type_code), getMode(target), getMode(arg1), getMode(arg2), type_code, type_code, type_code, getNum(target), getNum(arg1), getNum(arg2));
            i_list.push_back(*new_inst);
}

void parse_label(){
            char *a;
            a = strtok(yylval.str," :%?");
            int i = 0;
            char* name;
            while(a!=NULL){
                switch(i){
                    case 0 : break; 
                    case 1 :
                        name = strdup(a); break; 
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " :?%");
            }
            Instruction * new_inst ; 
            new_inst = new Instruction(LABEL_ST, name, CONSTANT_VAL, STRING);
            i_list.push_back(*new_inst);
}

void parse_goto(int flag){
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
                        if(flag)    op_string = strdup(a); else branch = strdup(a); break;
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
    Instruction* new_inst;
    if(flag){   
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
        Type type_val = INT;
        new_inst = new Instruction(gotoop, branch , getEntry(arg1, type_val), getEntry(arg2, type_val), CONSTANT_VAL, getMode(arg1), getMode(arg2), BRANCH, INT , INT, -1, getNum(arg1), getNum(arg2));
    } else {
        new_inst = new Instruction(GOTO, arg1, CONSTANT_VAL, BRANCH);     
    }
    i_list.push_back(*new_inst);
}

int num_args(char* arg_list){
            int i = 0;
            char* a;
            char* list = strdup(arg_list);
            a = strtok(list," ,");
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
       a = strtok(NULL, " ,.");
    } while((a) != NULL);
}

void parse_function(){ // function to parse the start of function
            char* a;
            a = strtok(yylval.str,";");
            int i = 0;
            char* name;
            char* arg_list;
            char* arg_lst;
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
                a = strtok(NULL, ";");
            }
    int* num ; 
    num = new int;
    *num = num_args(arg_list);
    Instruction* new_inst;
    new_inst = new Instruction(FUNC_ST, name, rtype, num,CONSTANT_VAL, CONSTANT_VAL, CONSTANT_VAL, STRING, STRING, INT );
    i_list.push_back(*new_inst);
    push_args(arg_list);
}

void function_end(){
    Instruction* new_instr;
    new_instr = new Instruction(FUNC_ET);
    i_list.push_back(*new_instr);
}

void parse_return(){
    char* a;
    a = strtok(yylval.str," %");
    int i = 0;
    char* rval;
            while(a!=NULL){
                switch(i){
                    case 0 : break; 
                    case 1 :
                        rval = strdup(a); break; 
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " %");
            }
    Instruction* new_inst;
    new_inst = new Instruction(RET, getEntry(rval, INT), getMode(rval) ,INT);
    i_list.push_back(*new_inst);
}

void parse_call(int imme){
    char* a;
    a = strtok(yylval.str," %:.=");
    int i = 0;
    char* fname;
    char* rvar, *rtype;
            while(a!=NULL){
                switch(i){
                    case 0 : if(imme) rvar = strdup(a); break; 
                    case 1 :
                        if(imme) rtype = strdup(a); else fname = strdup(a); break; 
                    case 2 : break;
                    case 3 : 
                        if(imme) fname = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " %:.=");
            }
    Instruction* new_inst;
    if(!imme) new_inst = new Instruction(CALL, fname, CONSTANT_VAL , STRING);
    else {
        Type type = type_parse(rtype);
        new_inst = new Instruction(CALL, fname, getEntry(rvar, type), CONSTANT_VAL , getMode(rvar), STRING, type, getNum(rvar)); 
    }
    i_list.push_back(*new_inst);    
}

void parse_get_addr(){
    char* a;
    a = strtok(yylval.str," %:.");
    int i = 0;
    char* target, *type_str, *source, *vtype_str;
            while(a!=NULL){
                switch(i){
                    case 0 : target = strdup(a); break; 
                    case 1 : 
                        type_str = strdup(a); break;
                    case 2 : 
                        source = strdup(a); break;
                    case 3: vtype_str = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " %:.");
            }
    Type type_var = type_parse(type_str);
    Type var_type = type_parse(vtype_str);
    Instruction new_inst(GETADDR, getEntry(target, type_var), getEntry(source, var_type), getMode(target), getMode(source), type_var, var_type, getNum(target), getNum(source));
    i_list.push_back(new_inst);
}
void parse_fptr(){
    char* a;
    a = strtok(yylval.str," %:.");
    int i = 0;
    char* target, *type_str, *source, *vtype_str;
            while(a!=NULL){
                switch(i){
                    case 0 : target = strdup(a); break; 
                    case 1 : 
                        type_str = strdup(a); break;
                    case 2 : 
                        source = strdup(a); break;
                    case 3 : 
                        vtype_str = strdup(a); break;
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " %:.");
            }
    Type type_var = type_parse(type_str);
    Type var_type = PTR;
    Instruction new_inst(FOLLOWPTR, getEntry(target, type_var), getEntry(source, var_type), getMode(target), getMode(source), type_var, var_type, getNum(target), getNum(source));
    i_list.push_back(new_inst);
}
void parse_pint(){
    char* a;
    a = strtok(yylval.str," %:.");
    int i = 0;
    char* target;
            while(a!=NULL){
                switch(i){
                    case 1: target = strdup(a); break; 
                    default : 
                        break;
                }
                i++;
                a = strtok(NULL, " %:.");
            }
    Instruction new_inst(PRINTINT, getEntry(target, INT), getMode(target), INT, getNum(target));
    i_list.push_back(new_inst);
}

IR load (int argc, char** argv)
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
                case GOTOSTMT : parse_goto(1); break;
                case GOTO : parse_goto(0); break;
                case FUNCTION_START : parse_function(); break;
                case UN_ASSIGNMENT : unary_op(1); break;
                case UN_OP : unary_op(0); break;
                case FUNCTION_END : function_end();  break;
                case LABELSTMT : parse_label(); break;
                case RETURN : parse_return(); break;
                case CALL_FN : parse_call(0); break;
                case CALL_FN_RET : parse_call(1); break;
                case GADDR : parse_get_addr(); break;
                case FPTR : parse_fptr(); break;
                case PINT : parse_pint(); break;
            }
    }
    for(int iter = 0; iter < i_list.size() ; iter++)
        i_list[iter].printInstruction();
    IR ir(i_list, &symtab);
    return ir;
}
