
%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string.h>
#include "helpers.h"
#include "Type.h"
#include <typeinfo>
#include "x86generator.h"
using namespace std;
#define YY_DECL extern "C" int yylex()
#define YYDEBUG 1
YY_DECL;
extern "C" int yyparse();
extern "C" FILE *yyin;
void yyerror(const char *s);

#include "Node.h"
ST* root = new ST(0, nullptr);
ST* curr = root;
vector<Instruction*> finalInstList;

%}

%code requires {
    #include "Node.h"
}

%locations
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
%token   <str>          AS
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
%token   <str>          INC 96
%token   <str>          DEC 97
%token   <str>          DECL 98
%token   <str>          PTR_OP 109
%token   <str>          STMTEND 111
%token   <str>          TRUE 112
%token   <str>          FALSE 113
%token   <str>          REL_OP 114
%token   <str>          ADD_OP 115
%token   <str>          NOT_OP
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
%token   <str>          SQ_PIPE_OPEN
%token   <str>          SQ_PIPE_CLOSE
%token   <str>          BREAK 129
%token   <str>          COLON 130


%left <str> OR
%left <str> AND
%left <str> EQ NE GE GT LE LT
%left <str> ADD SUB BIT_OR
%left <str> STAR DIV MOD LS RS AMPERSAND NOT_AND CARET

%error-verbose


%type		<nt>		StartSymbol
%type		<nt>		SourceFile
%type		<nt>		Package
%type		<nt>		Imports
%type		<nt>		Import
%type		<nt>		ImportStatement
%type		<nt>		ImportStatementList
%type		<nt>		Ostmtend
%type		<nt>		DeclarationList
%type		<nt>		Declaration
%type		<nt>		CommonDeclaration
%type		<nt>		VarDeclaration
%type		<nt>		ConstDeclaration
%type		<nt>		DeclarationNameList
%type		<nt>		DeclarationName
%type		<nt>		PointerType
%type		<nt>		StructType
%type		<nt>		StructDeclarationList
%type		<nt>		StructDeclaration
%type		<nt>		Embed
%type		<nt>		PackName
%type		<nt>		NewNameList
%type		<nt>		TypeName
%type		<nt>		VarDeclarationList
%type		<nt>		ConstDeclarationList
%type		<nt>		TypeDeclaration
%type		<nt>		TypeDeclarationName
%type		<nt>		TypeDeclarationList
%type		<nt>		Expression
%type		<nt>		OExpression
%type		<nt>		UnaryExpr
%type		<nt>		PrimaryExpr
%type		<nt>		ExpressionOrType
%type		<nt>		DotName
%type		<nt>		PrimaryExprNoParen
%type		<nt>		NonExpressionType
%type		<nt>		OtherType
%type		<nt>		NewName
%type		<nt>		ONewName
%type		<nt>		Name
%type		<nt>		ExpressionList
%type		<nt>		OExpressionList
%type		<nt>		OLiteral
%type		<nt>		Literal
%type		<nt>		FunctionDeclaration
%type		<nt>		GeneratorDeclaration
%type		<nt>		FunctionHeader
%type		<nt>		ConvType
%type		<nt>		CompType
%type		<nt>		FunctionType
%type		<nt>		GeneratorType
%type		<nt>		FunctionResult
%type		<nt>		FunctionReturnType
%type		<nt>		FunctionBody
%type		<nt>		OArgumentTypeListOComma
%type		<nt>		ArgumentTypeList
%type		<nt>		ArgumentType
%type		<nt>		NameOrType
%type		<nt>		OComma
%type		<nt>		OSimpleStatement
%type		<nt>		SimpleStatement
%type		<nt>		CompoundStatement
%type		<nt>		StatementList
%type		<nt>		Statement
%type		<nt>		NonDeclarationStatement
%type		<nt>		LabelName
%type		<nt>		IfStatement
%type		<nt>		ElseIf
%type		<nt>		ElseIfList
%type		<nt>		Else
%type		<nt>		LoopBody
%type		<nt>		IfHeader
%type		<nt>		ForStatement
%type		<nt>		ForBody
%type		<nt>		ForHeader
%type		<nt>		RangeStatement
%type		<nt>		SwitchStatement
%type		<nt>		CaseBlockList
%type		<nt>		CaseBlock
%type		<nt>		Case
%type		<nt>		ExpressionOrTypeList
%type		<nt>		InterfaceDeclaration
%type		<nt>		InterfaceDecl
%type		<nt>		InterfaceDeclarationList
%type		<nt>		InterfaceType
%type		<nt>		FunctionLiteral
%type		<nt>		GeneratorLiteral
%type		<nt>		FunctionLiteralDeclaration
%type		<nt>		GeneratorLiteralDeclaration
%type		<nt>		KeyVal
%type		<nt>		KeyValList
%type		<nt>		BareCompLiteralExpression
%type		<nt>		CompLiteralExpression
%type		<nt>		BracedKeyValList
%type		<nt>		TypeNameList
%type		<nt>		GenericType
%type		<nt>		GenericTypeList
%type		<nt>		OGenericTypeList
%type		<nt>		PseudoCall
%%

StartSymbol  :
{ fillTypeList();}SourceFile{
$$ = new Node("StartSymbol", new BasicType("NOTYPE"));
$$->Add($2);
$$->PrintJS();
}

;
SourceFile  :
Package Imports DeclarationList{
$$ = new Node("SourceFile", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$3->printInstructionList();
finalInstList = $3->instr_list;
}

;
Package  :
PACKAGE ID STMTEND{
$$ = new Node("Package", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}

;

Imports  :
%empty {$$ = new Node("Imports", new BasicType("NOTYPE"), 0);
$$->Add("");}		| Imports Import STMTEND{$$ = new Node("Imports", new BasicType("NOTYPE"), $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3)
;}

;
Import  :
IMPORT ImportStatement{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
}
		| IMPORT PAREN_OPEN ImportStatementList Ostmtend PAREN_CLOSE{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
}
		| IMPORT PAREN_OPEN PAREN_CLOSE{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}

;
ImportStatement  :
Literal{$$ = $1;}
		| ID Literal{$$ = new Node("ImportStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
}
		| DOT Literal{$$ = new Node("ImportStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
}

;
ImportStatementList  :
ImportStatement{$$ = new Node("ImportStatement", new BasicType("NOTYPE")); $$->Add($1);}
		| ImportStatementList STMTEND ImportStatement{$$ = $1; $$->incrementCount($3);}

;
Ostmtend  :
%empty {$$ = new Node("Ostmtend", new BasicType("NOTYPE"), 0);
$$->Add("");}		| STMTEND{$$ = new Node("Ostmtend", new BasicType("NOTYPE"));
$$->Add($1);
}

;
DeclarationList  :
%empty {$$ = new Node("DeclarationList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| DeclarationList Declaration STMTEND{$$ = $1; $$->incrementCount($2);
$$->instr_list = mergeInstructions($$->instr_list, $2->instr_list);
}

;
Declaration  :
CommonDeclaration{$$ = $1;}
		| FunctionDeclaration{$$ = $1;}
		| GeneratorDeclaration{$$ = $1;}

;
CommonDeclaration  :
          VAR VarDeclaration{$$ = $2;
}
        | VAR PAREN_OPEN VarDeclarationList Ostmtend PAREN_CLOSE{
$$ = $3;
}
        | VAR PAREN_OPEN PAREN_CLOSE{
// TODO: somehow denote the uselessness of this branch
}
        |CONST ConstDeclaration{
$$ = $2;
}
        |CONST PAREN_OPEN ConstDeclarationList Ostmtend PAREN_CLOSE{
$$ = $3;
}
       |CONST PAREN_OPEN PAREN_CLOSE{
// TODO: Somehow denote this is useless
}
		| TYPE TypeDeclaration{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$ = $2;
}
		| TYPE PAREN_OPEN TypeDeclarationList Ostmtend PAREN_CLOSE{
$$ = $3;
}
		| TYPE PAREN_OPEN PAREN_CLOSE{
// TODO: Somehow denote this is useless
}

;
VarDeclaration  :
DeclarationNameList ASSGN_OP { setRValueMode(true, curr); } ExpressionList {
setRValueMode(false, curr);
$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($4);
inferListType($1, $4); // : Add symbol table entry creation here
populateSTInfer($1, curr);
$$->instr_list = mergeInstructions($4->instr_list, generateInstructionsAssignment($1, $4, curr));
}
| DeclarationNameList TypeName{$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
populateST($1, $2, curr);
}
| DeclarationNameList TypeName ASSGN_OP { setRValueMode(true, curr); } ExpressionList{
setRValueMode(false, curr);
$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($5);
populateST($1, $2, curr);
$$->type_child = repeatType($2, $1->children.size());
checkListType($$->type_child, $5);
$$->instr_list = mergeInstructions($5->instr_list, generateInstructionsAssignment($1, $5, curr));
}

;
ConstDeclaration  :
DeclarationNameList ASSGN_OP { setRValueMode(true, curr); } ExpressionList{
setRValueMode(false, curr);
$$ = new Node("ConstDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($4);
inferListType($1, $4); // : Add symbol table entry creation here
populateST($1, $1, curr);
$$->instr_list = mergeInstructions($4->instr_list, generateInstructionsAssignment($1, $4, curr));
}
| DeclarationNameList TypeName ASSGN_OP { setRValueMode (true, curr); } ExpressionList{
setRValueMode(false, curr);
$$ = new Node("ConstDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($5);
populateST($1, $2, curr);
$$->type_child = repeatType($2, $1->children.size());
checkListType($$->type_child, $5);
$$->instr_list = mergeInstructions($5->instr_list, generateInstructionsAssignment($1, $5, curr));
}

;
DeclarationNameList  :
DeclarationName{$$ = new Node("Declaration Name List", new BasicType("NOTYPE")); $$->Add($1); }
		| DeclarationNameList COMMA DeclarationName{$$ = $1; $$->incrementCount($3);}

;
DeclarationName  :
ID{$$ = new Node("Declaration Name", new BasicType("NOTYPE")); $$->tmp = $1; $$->Add($1);}

;
PointerType  :
STAR TypeName{$$ = new Node("PointerType", new PointerType($2->getType()));
$$->Add($1);
$$->Add($2);}

;
StructType  :
STRUCT OGenericTypeList BLOCK_OPEN StructDeclarationList Ostmtend BLOCK_CLOSE{$$ = new Node("StructType", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
vector<string> fieldNames = getNames($4);
vector<Type*> typeList = getTypes($4);
StructDefinitionType* t = new StructDefinitionType(fieldNames, typeList);
$$->setType(t);
}
		| STRUCT OGenericTypeList BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("StructType", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
vector <string> fieldNames;
vector<Type*> typeList;
$$->setType(new StructDefinitionType(fieldNames, typeList));
}

;
StructDeclarationList  :
StructDeclaration{$$ = new Node("Struct Declaration", $$->getType()); $$->Add($1); $$->content = $1->content;}
| StructDeclarationList STMTEND StructDeclaration{$$ = $1; $1->incrementCount($3);}

;
StructDeclaration  :
NewNameList TypeName OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->str_child = getNameList($1);
$$->type_child = repeatType($2, $$->str_child.size());
if ($3->getType() != new BasicType("NOTYPE"))
    $$->content = $3->content;
$$->count = 2;
}
| Embed OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->setType($1->getType());
if ($2->getType() != new BasicType("NOTYPE"))
    $$->content = $2->content;
}
		| PAREN_OPEN Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->setType($2->getType());
if ($4->getType() != new BasicType("NOTYPE"))
    $$->content = $4->content;
}
		| STAR Embed OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->setType(new PointerType($2->getType()));
if ($3->getType() != new BasicType("NOTYPE"))
    $$->content = $3->content;
}
        | PAREN_OPEN STAR Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->setType(new PointerType($3->getType()));
if ($5->getType() != new BasicType("NOTYPE"))
    $$->content = $5->content;
}
		| STAR PAREN_OPEN Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->setType(new PointerType($3->getType()));
if ($5->getType() != new BasicType("NOTYPE"))
    $$->content = $5->content;
}
;
Embed  :
PackName{$$ = $1;}

;
PackName  :
ID DOT ID{$$ = new Node("PackName", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
string s1, s2, s3;
s1 = $1; s2 = "." ; s3 = $3;
s1 = s1 + s2 + s3;
$$->setType(new BasicType(s1));
}
| ID{$$ = new Node("PackName", new BasicType("NOTYPE")); $$->Add($1); $$->setType(new BasicType($1)); }

;
NewNameList  :
NewName{$$ = new Node("NewName",new BasicType("NOTYPE")); $$->Add($1);}
		| NewNameList COMMA NewName{$$ = $1; $$->incrementCount($3);}

;
TypeName  :
FunctionType{$$ = $1;}
        | GeneratorType{$$ = $1;}
		| PointerType{$$ = $1;}
		| OtherType{$$ = $1;}
		| DotName{$$ = $1;
              // Change Type if it turns out to be a struct. This is p hacky -Abhibhav
              if (ST::checkEntryStruct($1->content)) {
                StructDefinitionType* temp = ST::structDefs[$1->content];
                StructType* t = new StructType(temp, $1->content, temp->mem_size);
                $1->setType(t);
              }
    
    }
		| PAREN_OPEN TypeName PAREN_CLOSE{$$ = $2;}

;
VarDeclarationList  :
VarDeclarationList STMTEND VarDeclaration{$$ = $1; $$->incrementCount($3); }
		| VarDeclaration{$$ = new Node("VarDeclaration", new BasicType("NOTYPE")); $$->Add($1);}

;
ConstDeclarationList  :
ConstDeclaration{$$ = new Node("Constant Declaration", new BasicType("NOTYPE")); $$->Add($1);}
		| ConstDeclarationList STMTEND ConstDeclaration{$$ = $1; $$->incrementCount($3);}

;
TypeDeclaration  :
TypeDeclarationName TypeName{$$ = new Node("TypeDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
if (!($2->children[0]->matched).compare("struct")) {
  ST::structDefs[$1->children[0]->matched] = (StructDefinitionType*)$2->getType();
}

if (!($2->children[0]->matched).compare("interface")) {
  // Use stack to create a new interfacetype object
  InterfaceType* t = new InterfaceType($1->children[0]->matched, ST::interfaceStack);
  ST::interfaceStack.clear();
  ST::interfaceList[$1->children[0]->matched] = t;
}

}

;
TypeDeclarationName  :
ID{$$ = new Node("TypeDeclarationName", new BasicType("NOTYPE"));
$$->Add($1);
}

;
TypeDeclarationList  :
TypeDeclaration{$$ = new Node("TypeDeclaration", new BasicType("NOTYPE")); $$->Add($1);}
		| TypeDeclarationList STMTEND TypeDeclaration{$$ = $1; $$->incrementCount($3); }

;
Expression  :
Expression STAR Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(MUL_OPER, $$, $1, $3, curr);
}

		| Expression DIV Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(DIV_OP, $$, $1, $3, curr);
}
		| Expression MOD Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(MOD_OP, $$, $1, $3, curr);
}
		| Expression LS Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(SL_OP, $$, $1, $3, curr);
}
		| Expression RS Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(SR_OP, $$, $1, $3, curr);
}
		| Expression AMPERSAND Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(BAND_OP, $$, $1, $3, curr);
}
		| Expression NOT_AND Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(NAND_OP, $$, $1, $3, curr);
}
		| Expression ADD Expression{$$ = new Node("Expression", $1->getType());
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(ADD_OPER, $$, $1, $3, curr);
}
		| Expression SUB Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(SUB_OP, $$, $1, $3, curr);
}
		| Expression BIT_OR Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(BOR_OP, $$, $1, $3, curr);
}
		| Expression CARET Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(NOT_OPER, $$, $1, $3, curr);
}
		| Expression AND Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(AND_OP, $$, $1, $3, curr);
}
		| Expression OR Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(OR_OP, $$, $1, $3, curr);
}
		| Expression EQ Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(EQ_OP, $$, $1, $3, curr);
}
		| Expression NE Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(NEQ_OP, $$, $1, $3, curr);
}
		| Expression GE Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(GEQ_OP, $$, $1, $3, curr);
}
		| Expression GT Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(GT_OP, $$, $1, $3, curr);
}
		| Expression LE Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(LEQ_OP, $$, $1, $3, curr);
}
		| Expression LT Expression{$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
genInstructionBinWrapper(LT_OP, $$, $1, $3, curr);
}
		| UnaryExpr{ $$ = $1;$$->setType($1->getType()); 
            if((!$1->matched.compare("Name")) || (!$1->matched.compare("Literal")))
                $$->tmp = $$->content; 
}

;
OExpression  :
%empty {$$ = new Node("OExpression", new BasicType("NOTYPE"), 0);
$$->Add("");}		| Expression{$$ = $1;}

;
UnaryExpr  :
STAR UnaryExpr{
$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
if (isRValueMode(curr)) {
  $$->instr_list = $2->instr_list;
  $$->instr_list.push_back(generateUnaryInstruction(FOLLOWPTR, $2, curr));
  $$->tmp = getTemp($$);
  // Make sure that $2 is a pointer type
  // Or... just assume that it is so!
  PointerType* t = (PointerType*) $2->getType();
  $$->setType(t->GetUnderlyingType());
} else {
    $$->matched = "PointerWrite";
}
  $$->addrMode = REGISTER;
}
		| AMPERSAND UnaryExpr{
$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $2->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(GETADDR, $2, curr));
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
$$->setType(new PointerType($2->getType()));
}
		| ADD UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $2->instr_list;
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
$$->setType($2->getType());
}
		| SUB UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $2->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(NEG, $2, curr));
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
$$->setType($2->getType());
$$->tmp = getTemp($$);
}
		| NOT_OP UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $2->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(LNOT, $2, curr));
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
$$->setType($2->getType());
}
		| PrimaryExpr{$$ = $1;$$->setType($1->getType());}
;
PrimaryExpr  :
PrimaryExprNoParen{$$ = $1;$$->setType($1->getType());
if (!$1->matched.compare("ArrayAccess")) { // shifted here to n-d array access
if(curr->rValueMode){
    $1->instr_list = mergeInstructions($1->instr_list, generateInstructionReadArray($$, curr));
} else {
    $$->patchInstruction =  generateInstructionWriteArray($$, curr); 
}
}

if (!$1->matched.compare("StructAccess")) { // shifted here to n-d array access
if(curr->rValueMode){
		Node* t = new Node("Literal", new BasicType("NOTYPE"));
    // Need to extract the array offset
    /*$1->children[2] is the member variable and children[0] the name*/
    StructDefinitionType* n = ST::structDefs[(curr->structs)[$$->children[0]->content]];
    string number = to_string((n->offset)[$$->children[2]->matched]);
    Type* ty = (n->fields)[$$->children[2]->matched];
    t->Add(number);
    t->setType(new BasicType("int"));
    t->content = number;
    t->tmp = number;

    $1->instr_list = mergeInstructions($1->instr_list, generateInstructionReadStruct($$, $$->children[0], t, ty, curr));

} else {
    /* cout << "pob" << ($1->children).size() << endl; */
    /* cout << ($1->children)[0]->content << endl; */
    /* cout << ($1->children)[1]->matched << endl; */
    /* cout << ($1->children)[2]->matched << endl; */

		Node* t = new Node("Literal", new BasicType("NOTYPE"));
    StructDefinitionType* n = ST::structDefs[(curr->structs)[$$->children[0]->content]];
    Type* ty = (n->fields)[$$->children[2]->matched];
    string number = to_string((n->offset)[$$->children[2]->matched]);
    t->Add(number);
    t->setType(new BasicType("int"));
    t->content = number;
    t->tmp = number;

    $$->patchInstruction =  generateInstructionWriteStruct($$, $$->children[0], t, ty, curr);
}
}

}
		| PAREN_OPEN ExpressionOrType PAREN_CLOSE{$$ = $2; }

;
ExpressionOrType  :
Expression{$$ = $1;$$->setType($1->getType());}
		| NonExpressionType{$$ = $1;}

;
DotName  :
Name{$$ = $1;}
		| Name DOT ID{
string s = $1->content;
string s1  = ".";
string s3;
string s2 = $3;
s = s + s1 + s3;
$$ = new Node("DotName", new BasicType(s));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}


;
PrimaryExprNoParen  :
Name {
$$ = $1;
$$->addrMode = REGISTER;
}
| Literal{
$$ = $1;$$->setType($1->getType());
$$->addrMode = CONSTANT_VAL;
}
| PrimaryExpr DOT ID{$$ = new Node("StructAccess", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
string s = ".";
string s1 = $3;
s = s + s1 ;
s = $1->getType()->GetRepresentation() + s;
$$->setType(new BasicType(s));
}
| PrimaryExpr DOT PAREN_OPEN ExpressionOrType PAREN_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->setType(new BasicType("NOTYPE")); // TODO : do after function call
}
		| PrimaryExpr DOT PAREN_OPEN TYPE PAREN_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE")); // for type switching, does not need to be done
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
semanticError("Unimplemented runtime feature being used!");
}
		| PrimaryExpr SQUARE_OPEN Expression SQUARE_CLOSE{$$ = new Node("ArrayAccess", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->content = $1->content;
$$->instr_list = mergeInstructions($1->instr_list, $3->instr_list);
$$->str_child = $1->str_child;
if(!$3->matched.compare("Literal")){
    string str = "temp" + to_string(clock());
    curr->addEntry(str,$3->getType() ,false);
    $$->instr_list.push_back(new Instruction(ASG, correctPointer(str, curr),
                            correctPointer($3,curr),
                            REGISTER, CONSTANT_VAL,
                            $3->getType(), $3->getType()
                            ));
    $3->tmp = str;
}
$$->str_child.push_back($3->tmp);
}
| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE")) ; // TODO : slices
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
}
| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE")); // TODO : slices
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
$$->Add($7);
$$->Add($8);
}
		| ConvType AS PAREN_OPEN Expression OComma PAREN_CLOSE{
$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
$$ = $1;
$$->setType($4->getType());
/* $$->Add($1); */
/* $$->Add($2); */
/* $$->Add($3); */
/* $$->Add($4); */
/* $$->Add($5); */
//$$->Add($6); // type conversion
// TODO : do type checking here
}
                | CompType BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4); // TODO : array / slice assignment (variadic example)
}
		| PrimaryExprNoParen SQ_PIPE_OPEN BracedKeyValList SQ_PIPE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4); // TODO : figure out what this does
}
| FunctionLiteral{$$ = $1;} // TODO : handle function calls, do type checking for function call
| GeneratorLiteral{$$ = $1;}
| PseudoCall {
  $$ = $1;
} // TODO: handle type checking of pseudocall
            // get type of function return type here
;
NonExpressionType  :
FunctionType{$$ = $1;}
		| GeneratorType{$$ = $1;}
		| OtherType{$$ = $1;}
		| STAR NonExpressionType{$$ = new Node("NonExpressionType", new PointerType($2->getType()));
$$->Add($1);
$$->Add($2);}

;
OtherType  :
SQUARE_OPEN OExpression SQUARE_CLOSE TypeName{
if($2->count != 0 && ($4->matched == "Name")) {
    $$ = new Node("OtherType", new ArrayType($4->getType(), atoi($2->content.c_str())) );
    $$->getType()->mem_size*= atoi($2->content.c_str());
} else if ($4->matched == "Name") {
    // TODO : slice Type
} else if ($2->count != 0 && $4->getType()->GetTypeClass()==4) {
   // n-d array 
   // layout is memory inefficient
   $$ = new Node("ArrayType", new ArrayType($4->getType(), atoi($2->content.c_str()) ) );
   $$->getType()->mem_size = atoi($2->content.c_str())*$4->getType()->GetMemSize();
} else {    
    // weird case
}
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);}
		| SQUARE_OPEN VARIADIC SQUARE_CLOSE TypeName{$$ = new Node("OtherType", new ArrayType($4->getType(), 0, true));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
}
		| StructType{$$ = $1;}
		| InterfaceType{$$ = $1;}

;
NewName  :
ID{$$ = new Node("Name", new BasicType("NOTYPE")); $$->Add($1); $$->content = $1;
$$->setType(new BasicType($1));
}

;
ONewName  :
%empty {$$ = new Node("Empty New Name", new BasicType("NOTYPE"), 0); $$->Add("");}
| NewName{$$ = $1;}

;
Name  :
ID {$$ = new Node("Name", new BasicType("NOTYPE")); $$->Add($1); $$->setType(new BasicType($1));
$$->content = $1;
}

;
ExpressionList  :
         Expression {
// All expressionsLists finally end up as expressions!
$$ = new Node("Expression", new BasicType("NOTYPE"));
$$->Add($1);
$$->instr_list = mergeInstructions($$->instr_list, $1->instr_list);
}
        | ExpressionList COMMA Expression {
$$ = $1;
$$->incrementCount($3);
$$->instr_list = mergeInstructions($$->instr_list, $3->instr_list);
}

;
OExpressionList  :
%empty {$$ = new Node("Empty Expression List", new BasicType("NOTYPE"), 0);}
    | ExpressionList{$$ = $1;}

;
OLiteral  :
%empty {$$ = new Node("Empty Literal", new BasicType("NOTYPE"), 0);}
| Literal{$$ = $1; $$->setType($1->getType());}

;
Literal  :
RAW_STRING{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1); $$->setType(new BasicType("str")); $$->content = $1; $$->tmp = $1;}
		| INTER_STRING{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("byte")); $$->content = $1;$$->tmp = $1;}
		| DECIMAL_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("int")); $$->content = $1;$$->tmp = $1;}
		| OCTAL_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("octal")); $$->content = $1;$$->tmp = $1;}
		| HEX_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("hex")); $$->content = $1;$$->tmp = $1;}
		| TRUE{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("bool")); $$->content = $1;$$->tmp = $1;}
		| FALSE{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("bool")); $$->content = $1;$$->tmp = $1;}

;
FunctionDeclaration  :
FUNC OGenericTypeList { ST::paramPush = true;
ST* t = new ST(curr->depth + 1, curr);
curr->addChild(t);
curr = t;
}
FunctionHeader {

vector<Type*> paramTypes = createParamList($4->children[2]);
vector<string> paramNames = createNameList($4->children[2]);
populateSTTypeList(paramNames, paramTypes, curr);
if (($4->children).size() == 5) {
  FuncType* t = new FuncType($4->children[4]->getType(), paramTypes);
  ST::funcDefs.insert(pair<string, FuncType*>( ($4->children[0])->matched, t));
  ST::funcSTs[($4->children[0])->matched] = curr;
  ST::funcParamNamesInOrder[($4->children[0])->matched] = paramNames;
  if (ST::structPush) {
    (ST::structDefs[ST::structName]->structFunctions)[ST::funcName] = t;

    // Check if the new function made the struct implement some new interface

    /*map<string, InterfaceType*>::iterator it;*/
    /*map<string, FuncType*>::iterator it2;*/
    /*for (it = ST::interfaceList.begin(); it != ST::interfaceList.end(); it++) {*/
      /*for (it2 = ((*it)->second).funcList.begin(); it2 != (*it)->second->funcList.end(); it2++) {*/
        /*;*/
      /*}*/
    /*}*/

    ST::structPush = false;
    ST::structName = "";
    ST::funcName = "";
  }
} else {
  // Throw error!
  semanticError("Unexpected function declaration.", true);
}
ST::paramPush = false;

}
FunctionBody{$$ = new Node("FunctionDeclaration", new BasicType("NOTYPE"), $2->count, $4->flag);
$$->Add($1);
$$->Add($2);
$$->Add($4);
$$->Add($6);
string * name = getCharFromString($4->children[0]->matched);
$$->instr_list.push_back(new Instruction(  FUNC_ST  , name, STRING, new BasicType("function_name")));
$$->instr_list = mergeInstructions($$->instr_list, mergeInstructions($4->instr_list, $6->instr_list));
$$->instr_list.push_back(new Instruction(  FUNC_ET));
/* curr->funcDefs.insert(pair<string, FuncType*> ($4->content , (FuncType*)$4->getType())); */
}
;
GeneratorDeclaration  :
GEN OGenericTypeList { ST::paramPush = true;
ST* t = new ST(curr->depth + 1, curr);
curr->addChild(t);
curr = t;
}
FunctionHeader {

vector<Type*> paramTypes = createParamList($4->children[2]);
vector<string> paramNames = createNameList($4->children[2]);
populateSTTypeList(paramNames, paramTypes, curr);
if (($4->children).size() == 5) {
  FuncType* t = new FuncType($4->children[4]->getType(), paramTypes, true);
  ST::funcDefs.insert(pair<string, FuncType*>( ($4->children[0])->matched, t));
  ST::funcSTs[($4->children[0])->matched] = curr;
  ST::funcParamNamesInOrder[($4->children[0])->matched] = paramNames;
  if (ST::structPush) {
    (ST::structDefs[ST::structName]->structFunctions)[ST::funcName] = t;
    ST::structPush = false;
    ST::structName = "";
    ST::funcName = "";
  }
} else {
  // Throw error!
    semanticError("Unexpected generator declaration.", true);
}
ST::paramPush = false;

}
FunctionBody{$$ = new Node("GeneratorDeclaration", new BasicType("NOTYPE"), $2->count, $4->flag);
$$->Add($1);
$$->Add($2);
$$->Add($4);
$$->Add($6);
string * name = getCharFromString($4->children[0]->matched);
$$->instr_list.push_back(new Instruction(  FUNC_ST  , name, STRING, new BasicType("function_name")));
$$->instr_list = mergeInstructions($2->instr_list, $4->instr_list);
$$->instr_list.push_back(new Instruction(  FUNC_ET));
fn_map.insert(pair<string, FuncType*> ($4->content , (FuncType*)$4->getType()));
}
;

FunctionHeader  :
ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{
$$ = new Node("FunctionHeader", new BasicType("NOTYPE"), $3->count, $3->flag);
$$->Add($1);
$$->content = $4;
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
setScopeReturnType($5->getType(), curr);
vector<Type*> paramTypes;
if($3->count > 1){
    paramTypes = createParamList($3->children[0]);
    $$->setType(new FuncType($5->getType(), paramTypes));
} 
$$->setType(new FuncType($5->getType(), paramTypes));
}
| PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{
$$ = new Node("FunctionHeader", new BasicType("NOTYPE"), $2->count, $2->flag);
$$->Add($4); // ID
$$->content = $4;
$$->Add($5); // (
// Add stuff to the structdefinitiontype
ST::structPush = true;
ST::structName = $2->children[0]->children[1]->content;
ST::funcName = $4;
/*$2->children[0]->children.insert($2->children[0]->children.end(), $6->children[0]->children.begin(), $6->children[0]->children.end());*/
/*$2->children[0]->count = $2->count + $6->count;*/
$2->children.insert($2->children.end(), $6->children.begin(), $6->children.end());
$2->count = $2->count + $6->count;
$$->Add($2); // Fixed up argument list
$$->Add($7); // )
$$->Add($8); // FunctionResult
setScopeReturnType($8->getType(), curr);
if($6->count > 1){
    vector<Type*> paramTypes = createParamList($6->children[0]);
    $$->setType(new FuncType($8->getType(), paramTypes));
} else {
    vector<Type*> paramTypes;
    $$->setType(new FuncType($8->getType(), paramTypes));
}
}
;
ConvType  :
FunctionType{
$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);
}
		| GeneratorType{$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);
}
		| OtherType{$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);
}

;
CompType  :
OtherType{$$ = $1;}

;
FunctionType  :
FUNC OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
vector<Type*> paramTypes = createParamList($4->children[0]);
$$->setType(new FuncType($6->getType(), paramTypes));
}
;
GeneratorType  :
GEN OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("GeneratorType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
vector <Type*> paramTypes = createParamList($4->children[0]);
$$->setType(new FuncType($6->getType(), paramTypes, true));
}

;
FunctionResult  :
%empty {$$ = new Node("FunctionResult", new BasicType("NOTYPE"), 0);
$$->Add("");}		| FunctionReturnType{$$ = $1;}
		| PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE{$$ = new Node("FunctionResult", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
vector<Type*> paramTypes = createParamList($2->children[0]);
$$->setType(new CompoundType(paramTypes));
}

;
FunctionReturnType  :
FunctionType{$$ = $1;}
		| GeneratorType{$$ = $1;}
		| OtherType{$$ = $1; }
		| DotName{$$ = $1;}

;
FunctionBody  :
CompoundStatement{$$ = new Node("FunctionBody", new BasicType("NOTYPE"));
$$->Add($1);
$$->instr_list = $1->instr_list;
}
;

OArgumentTypeListOComma  :
%empty {
$$ = new Node("OArgumentTypeListOComma", new BasicType("NOTYPE"), 0);
}
        | ArgumentTypeList OComma {
$$ = $1;}

;
ArgumentTypeList  :
ArgumentType {$$ = new Node("ArgumentType", $1->getType()); $$->Add($1);}
        |       ArgumentTypeList COMMA ArgumentType{$$ = $1 ; $$->incrementCount($3);}

;
ArgumentType  :
NameOrType{$$ = $1; $$->count = 1;
}
		| ID NameOrType{$$ = new Node("ArgumentType", $2->getType()); $$->count = 2;
$$->Add($1);
$$->Add($2);$$->content = $1; }
		| ID VARIADIC{$$ = new Node("ArgumentType", new BasicType("NOTYPE"), 1, true); $$->count = 2;
$$->Add($1);
$$->Add($2);
}
		| VARIADIC TypeName{$$ = new Node("ArgumentType", $2->getType(), 1, true); $$->count = 2;
$$->Add($1);
$$->Add($2);
}
		| VARIADIC{$$ = new Node("ArgumentType", new BasicType("NOTYPE"), 1, true); $$->count = 2;
$$->Add($1); // TODO: handle this, since it opens possibility of no types being defined for the entire list
}

;
NameOrType  :
TypeName{$$ = $1;}

;
OComma  :
COMMA {
$$ = new Node("OComma", new BasicType("NOTYPE"));
$$->Add($1);
}
        | %empty {
$$ = new Node("OComma", new BasicType("NOTYPE"), 0);
$$->Add(",");
}
;
OSimpleStatement  :
%empty {$$ = new Node("OSimpleStatement", new BasicType("NOTYPE"), 0);
$$->Add("");}		| SimpleStatement{$$ = $1;}

;
SimpleStatement  :
Expression{ $$ = $1; }
| ExpressionList ASSGN_OP { setRValueMode(true, curr); } ExpressionList {
    setRValueMode(false, curr);
$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($4);
$$->instr_list = mergeInstructions($1->instr_list, $4->instr_list);
$$->instr_list = mergeInstructions($$->instr_list, generateInstructionsAssignment($1, $4, curr));
// random line
int ijk = 0;
}
| ExpressionList DECL { setRValueMode(true, curr); } ExpressionList{
    setRValueMode(false, curr);
$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($4);inferListType($1, $4);
populateSTInfer($1, curr);
$$->instr_list = mergeInstructions($1->instr_list, $4->instr_list);
$$->instr_list = mergeInstructions($$->instr_list, generateInstructionsAssignment($1, $4, curr));
}
		| Expression INC{$$ = new Node("SimpleStatement", $1->getType());
$$->Add($1);
$$->Add($2);
$$->instr_list = $1->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(INC_OP, $1, curr));
$$->tmp = getTemp($$);
$$->instr_list.push_back(new Instruction(ASG, 
        correctPointer($1, curr),
        correctPointer($$, curr),
        REGISTER, REGISTER, 
        $$->getType(), $$->getType()));
$$->tmp = $1->tmp;
$$->addrMode = REGISTER;
}
		| Expression DEC{$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $1->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(DEC_OP, $1, curr));
$$->tmp = getTemp($$);
$$->instr_list.push_back(new Instruction(ASG, 
        correctPointer($1, curr),
        correctPointer($$, curr),
        REGISTER, REGISTER, 
        $$->getType(), $$->getType()));
$$->tmp = $1->tmp;
$$->addrMode = REGISTER;
}

;
CompoundStatement  :
BLOCK_OPEN {
  // This is when a new scope starts but only if this is not from a for/if/function header
  if (! ST::paramPush) {
    ST* t = new ST(curr->depth + 1, curr);
    curr->addChild(t);
    curr = t;
  }
}
StatementList {
  // This is where stuff ends
  curr = curr->parent;
}
BLOCK_CLOSE{
$$ = new Node("CompoundStatement", new BasicType("NOTYPE"), $3->count);
$$->Add($1);
$$->Add($3);
$$->Add($5);
// In all fairness, scoping is done by the STable, no need to deal with that here
// the add steps above are now redundant
$$ = $3;
}

;
StatementList  : // TODO  : this is also beginning of a scope, unhandled
Statement{$$ = new Node("StatementList", new BasicType("NOTYPE")); $$->Add($1); $$->flag = $1->flag; $$->instr_list = mergeInstructions($$->instr_list, $1->instr_list); }
		| StatementList STMTEND Statement{
$$ = $1;
$$->incrementCount($3);
$$->instr_list = mergeInstructions($$->instr_list, $3->instr_list);
if($3->flag)    $$->flag = $3->flag;
}

;
Statement  :
%empty {$$ = new Node("Statement", new BasicType("NOTYPE"), 0);
$$->Add("");}		| CompoundStatement{$$ = $1;}
		| CommonDeclaration{$$ = $1;}
		| NonDeclarationStatement{$$ = $1;}

;
NonDeclarationStatement  :
SimpleStatement{$$ = $1;}
		| IfStatement{$$ = $1;}
		| ForStatement{$$ = $1;}
		| SwitchStatement{$$ = $1;}
		| LabelName COLON Statement{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->instr_list.push_back(generateLabelInstruction($1->content));
$$->instr_list = mergeInstructions($$->instr_list, $3->instr_list);
string s = "label";
s = s + to_string(clock());
goto_label_map[$1->content] = s;
if($3->matched == "ForStatement"){
    break_label_map[$1->content] = $3->tmp;
    cont_label_map[$1->content] = $3->content;
}
backPatch(goto_map, $1->content);
backPatch(break_map, $1->content);
backPatch(cont_map, $1->content);
}

| FALLTHROUGH{$$ = new Node("NonDeclarationStatement", new BasicType("FallThrough"));
$$->Add($1);
$$->flag = 1;
//$$->instr_list.push_back(generateFallThroughInstruction()); // TODO : handling unclear of all the following
}
| BREAK ONewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
if($2->count  == 1){
    Instruction * instr = generateUnconditionalGoto(curr);
    if(!break_label_map.count($2->content))
        break_map[$2->content] = instr;
    else {
        *((string*)instr->getV1()) = $2->content;
    }
    $$->instr_list.push_back(instr);
}

}
| CONTINUE ONewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
if($2->count  == 1){
    Instruction * instr = generateUnconditionalGoto(curr);
    if(!cont_label_map.count($2->content))
        cont_map[$2->content] = instr;
    else {
        *((string*)instr->getV1()) = $2->content;
    }
    $$->instr_list.push_back(instr);
}
}
| GOTO NewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
    Instruction * instr = generateUnconditionalGoto(curr);
    if(!goto_label_map.count($2->content))
        goto_map[$2->content] = instr;
    else {
        *((string*)instr->getV1()) = $2->content;
    }
    $$->instr_list.push_back(instr);
}
| RETURN { setRValueMode(true, curr); } OExpressionList{
setRValueMode(false, curr);
$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($3);
generateReturn($$, $3, curr);
}
| YIELD { setRValueMode(true, curr); } OExpressionList{
setRValueMode(false, curr);
$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($3);
generateYield($$, $3, curr);
}

;
LabelName  :
NewName{$$ = $1;}

;
IfStatement  :
IF {ST::paramPush = true;
ST* t = new ST(curr->depth + 1, curr);
curr->addChild(t);
curr = t;
}
IfHeader {ST::paramPush = false;} 
LoopBody ElseIfList Else{$$ = new Node("IfStatement", new BasicType("NOTYPE"), $5->count);
$$->Add($5);
$$->Add($6);
$$->Add($7);
$$->instr_list = $3->instr_list;
for(int i=0; i< $6->count; ++i)
    $$->instr_list = mergeInstructions($$->instr_list,$6->children[i+1]->children[2]->instr_list); // weird bug here, must be indexed as 1 for some reason
Instruction* branch_goto = generateUnconditionalGoto(curr);
$$->instr_list.push_back(branch_goto);
string s = *(string *)$$->instr_list[$$->instr_list.size() - 1]->getV1();
string s1 = $3->getType()->GetRepresentation();
$$->instr_list.push_back(generateLabelInstruction(s1 ));
$$->instr_list = mergeInstructions($$->instr_list, $5->instr_list);
for(int i=0; i< $6->count; ++i){
    $$->instr_list.push_back(generateLabelInstruction($6->children[i+1]->getType()->GetRepresentation()));
    $$->instr_list = mergeInstructions($$->instr_list,$6->children[i+1]->children[3]->instr_list);
    $$->instr_list.push_back(branch_goto);
}
$$->instr_list.push_back(generateLabelInstruction(s));
if($7->count > 0)
    $$->instr_list = mergeInstructions($$->instr_list, $7->children[1]->instr_list);
}

;
ElseIf  :
ELSE IF {ST::paramPush = true;
ST* t = new ST(curr->depth + 1, curr);
curr->addChild(t);
curr = t;
}
IfHeader {ST::paramPush = false;} LoopBody{$$ = new Node("ElseIf", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($4);
$$->Add($6);
$$->instr_list = $4->instr_list;
$$->setType(new BasicType(*(string*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
 }
;
ElseIfList  :
%empty {$$ = new Node("Empty ElseIfList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| ElseIfList ElseIf{$$ = $1 ; $$->incrementCount($2);}

;
Else  :
%empty {$$ = new Node("Else", new BasicType("NOTYPE"), 0);
$$->Add("");}		| ELSE CompoundStatement{$$ = new Node("Else", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
//$$->instr_list = $2->instr_list;
$$->instr_list.push_back(generateGotoInstruction($2, curr));
$$->setType(new BasicType(*(string*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
}

;
LoopBody  :
CompoundStatement {$$ = $1; }

;
IfHeader  :
OSimpleStatement{$$ = new Node("IfHeader", new BasicType("label"));
$$->Add($1);
$$->instr_list = $1->instr_list;
$$->instr_list.push_back(generateGotoInstruction($1, curr));
$$->setType(new BasicType(*(string*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
$$->tmp = $$->getType()->GetRepresentation();
}
| OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("IfHeader", new BasicType("label"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->instr_list = mergeInstructions($1->instr_list, $3->instr_list);
$$->instr_list.push_back(generateGotoInstruction($3, curr));
$$->setType(new BasicType(*(string*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
}

;
ForStatement  :
FOR {ST::paramPush = true; ST::paramEntryStack.empty(); 
    ST* t = new ST(curr->depth + 1, curr);
    curr->addChild(t);
    curr = t;
}
ForBody{$$ = new Node("ForStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($3);
$$->instr_list = $3->instr_list;
$$->tmp = $3->tmp;
$$->content = $3->content;
}

;
ForBody  :
ForHeader {ST::paramPush = false;} LoopBody{$$ = new Node("ForBody", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($3);
if(($1->matched == "ForHeader")){
    string s1 = "forlabel" + to_string(clock());
    string s2 = "forlabel" + to_string(clock());
    $$->tmp = s2;
    $$->content = s1;
    $$->instr_list = mergeInstructions($$->instr_list, $1->children[0]->instr_list);
    $$->instr_list.push_back(generateLabelInstruction(s1));
    $$->instr_list = mergeInstructions($$->instr_list, $1->children[2]->instr_list);
    $$->instr_list.push_back(generateGotoInstruction($1->children[2],s2  ,curr, false));
    $$->instr_list = mergeInstructions($$->instr_list,$3->instr_list);
    $$->instr_list = mergeInstructions($$->instr_list, $1->children[4]->instr_list);
    $$->instr_list.push_back(generateUnconditionalGoto(s1,curr));
    $$->instr_list.push_back(generateLabelInstruction(s2));
} else if ($1->matched == "RangeStatement"){
    // TODO : handle range expression Milind
    string s1 = "forlabel" + to_string(clock());
    string s2 = "forlabel" + to_string(clock());
    $$->tmp = s2;
    $$->content = s1;
    if($1->count == 0){
        void* arg1 = correctPointer($1, curr);
        long * ptr = new long;
        *ptr = 0;
        $$->instr_list.push_back(new Instruction(ASG, arg1, ptr,
                                                    REGISTER, CONSTANT_VAL,
                                                    $1->getType(), 
                                                    new BasicType("int")));
        $$->instr_list.push_back(generateLabelInstruction(s1));
        long *ptr2 = new long; *ptr2 = 1;
        $1->tmp = "temp" + to_string(clock());
        curr->addEntry($1->tmp, new BasicType("bool"), false);
        void* arg2 = curr->getVar($1->tmp);
        $$->instr_list.push_back(new Instruction(LT_OP, arg2, arg1, ptr2,
                                                    REGISTER, 
                                                    REGISTER, 
                                                    CONSTANT_VAL,
                                                    new BasicType("bool"), $1->getType(),
                                                    new BasicType("long")
                                                    ));
        $$->instr_list.push_back(generateGotoInstruction($1,s2  ,curr, false));
        $$->instr_list = mergeInstructions($$->instr_list,$3->instr_list);
        $$->instr_list.push_back(new Instruction(ADD_OPER, arg1, arg1, ptr,
                                                REGISTER, REGISTER, CONSTANT_VAL, 
                                                $1->getType(), $1->getType(),
                                                new BasicType("int")));
        $$->instr_list.push_back(generateUnconditionalGoto(s1,curr));
        $$->instr_list.push_back(generateLabelInstruction(s2));

    } else {
       if($1->children[3]->matched != "Name"){
            semanticError("Can not iterate over literal / expression"); // TODO : handle slice
       } else  {
            STEntry * ste = curr->getVar($1->children[3]->content);
            if(!ste) semanticError("Can not find array");
            else {
                if(ste->getType()->GetTypeClass() != 4 || ((PointerType*)ste->getType())->GetUnderlyingType()->GetTypeClass() != 4 || *ste->getType() == *(new BasicType("string"))){
                    // handling array type
                    // strings not handled yet 
                    string s = "index" + to_string(clock()); // Index variable
                    string s3 = "value" + to_string(clock()); // Value variable
                    curr->addEntry(s, new BasicType("int"),false );
                    Node* mainChild = fixNodeForExpression($1->children[3], curr); // TODO : Milind add translation from pointer to array to array, so that it can be handled similarily in mainChild
                    Node* varChild = $1->children[0];
                    if(varChild->children.size() != 2){
                        semanticError("Can not handle more than 2 iterating variables for array enumeration");
                    } 
                    curr->addEntry(s3,((ArrayType*)mainChild->getType())->GetArrayType() ,false );
                    void* arg1 = curr->getVar(s);  
                    void * arg4 = curr->getVar(s3);
                    long * ptr = new long;
                    *ptr = 0;
                    $$->instr_list.push_back(new Instruction(ASG, arg1, ptr,
                                                    REGISTER, CONSTANT_VAL,
                                                    $1->getType(), 
                                                    new BasicType("int")));
                    $$->instr_list.push_back(generateLabelInstruction(s1));
                    long *ptr2 = new long; *ptr2 = ((STEntry*)arg1)->getType()->GetMemSize();
                    long *ptr3 = new long;
                    *ptr3 = ((ArrayType*)mainChild->getType())->GetSize();
                    $1->tmp = "temp" + to_string(clock()); // temporary var for keeping the LT_OP result
                    curr->addEntry($1->tmp, new BasicType("bool"), false);
                    void* arg2 = curr->getVar($1->tmp);
                    $$->instr_list.push_back(new Instruction(LT_OP, arg2, arg1, ptr3,
                                                    REGISTER, 
                                                    REGISTER, 
                                                    CONSTANT_VAL,
                                                    new BasicType("bool"), $1->getType(),
                                                    new BasicType("long")
                                                    ));
                    $$->instr_list.push_back(generateGotoInstruction($1,s2  ,curr, false));
                    $$->instr_list.push_back(new Instruction(EELEM, arg4 ,arg2,correctPointer(mainChild, curr),
                                                    REGISTER, REGISTER, REGISTER,
                                                    ((STEntry*)arg4)->getType(), new BasicType("int"),
                                                    mainChild->getType()));
                    if(varChild->children[0]->content != "_")   {
                        varChild->children[0] = fixNodeForExpression(varChild->children[0], curr);
                         if(!$1->flag){
                            curr->addEntry(varChild->children[0]->content, new BasicType("int"),false );
                         }
                         void *target1 = correctPointer(varChild->children[0], curr); 
                         $$->instr_list.push_back(new Instruction(COPY_OP, target1, arg1, REGISTER, REGISTER,
                                                    new BasicType("int"), new BasicType("int")
                                                    ));
                    }
                    if(varChild->children[1]->content != "_")   {
                        varChild->children[1] = fixNodeForExpression(varChild->children[1], curr);
                         if(!$1->flag){
                            curr->addEntry(varChild->children[1]->content, ((ArrayType*)mainChild->getType())->GetArrayType(),false );
                         }
                        void *target2 = correctPointer(varChild->children[1], curr);
                        $$->instr_list.push_back(new Instruction(COPY_OP, target2, arg4, REGISTER, REGISTER,
                                                    new BasicType("int"), new BasicType("int")
                                                    ));
                    }
                    $$->instr_list = mergeInstructions($$->instr_list,$3->instr_list);
                    $$->instr_list.push_back(new Instruction(ADD_OPER, arg1, arg1, ptr2,
                                                REGISTER, REGISTER, CONSTANT_VAL, 
                                                $1->getType(), $1->getType(),
                                                new BasicType("int")));
                    $$->instr_list.push_back(generateUnconditionalGoto(s1,curr));
                    $$->instr_list.push_back(generateLabelInstruction(s2));
                    int kjk = 10;
                } else {
                    semanticError("Non Array type or pointer to array type can not be iterated over");
                }
            }
       }
    }
} else {
    string s1 = "label" + to_string(clock());
    string s2 = "label" + to_string(clock());
    $$->instr_list.push_back(generateLabelInstruction(s1));
    $$->instr_list = mergeInstructions($$->instr_list, $1->instr_list);
    $$->instr_list.push_back(generateGotoInstruction($1,s2  ,curr, false));
    $$->instr_list.push_back(generateLabelInstruction(*((string*)$1->instr_list[$1->instr_list.size() - 1]->getV1())));
    $$->instr_list = mergeInstructions($$->instr_list,$3->instr_list);
    $$->instr_list.push_back(generateUnconditionalGoto(s1,curr));
    $$->instr_list.push_back(generateLabelInstruction(s2));

}
}

;
ForHeader  :
OSimpleStatement STMTEND OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("ForHeader", new BasicType("NOTYPE"), 3);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
}
		| OSimpleStatement{$$ = $1;}
		| RangeStatement{$$ = $1;}

;
RangeStatement  :
ExpressionList ASSGN_OP RANGE { setRValueMode(true, curr); } Expression{
setRValueMode(false, curr);
$$ = new Node("RangeStatement", new BasicType("NOTYPE"), $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($5);
}
| ExpressionList DECL RANGE { setRValueMode(true, curr); } Expression{
setRValueMode(false, curr);
$$ = new Node("RangeStatement", new BasicType("NOTYPE"), $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($5);
}
| RANGE { setRValueMode(true, curr); } Expression {
setRValueMode(false, curr);
$$ = new Node("RangeStatement", new BasicType("int"), 0);
$$->Add($1);
$$->Add($3);
string temp = "temp" + to_string(clock());
curr->addEntry(temp, $$->getType(), false);
$$->tmp = temp;

}
;
SwitchStatement  :
SWITCH IfHeader BLOCK_OPEN { setRValueMode(true, curr); } CaseBlockList BLOCK_CLOSE{
setRValueMode(false, curr);
$$ = new Node("SwitchStatement", new BasicType("NOTYPE"), $5->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($5);
$$->Add($6);
$$->instr_list = copyInstruction($2->instr_list,1);
vector<string> caseblock_label_list;
string end = "label" + to_string(clock());
for(int i=0; i<$5->count; ++i){
    string s = "label" + to_string(clock());
    caseblock_label_list.push_back(s);
    if($5->children[i+1]->children[0]->matched == "Default")
        continue;
    $$->instr_list = mergeInstructions($$->instr_list, $5->children[i+1]->children[0]->instr_list); // check the i+1
    Node * ptr = $5->children[i+1]->children[0]->children[1];
    for(int j=0; j<ptr->count; j++)
        $$->instr_list.push_back(generateEqualityInstruction($2->children[0]->children[0], ptr->children[j], curr, s));
}
for(int i=0; i<$5->count; ++i){
    $$->instr_list.push_back(generateLabelInstruction(caseblock_label_list[i]));
    $$->instr_list = mergeInstructions($$->instr_list, $5->children[i+1]->children[1]->instr_list);
    if(($5->children[i+1]->children[1]->flag) && !($5->children[i+1]->children[0]->matched == "Default"))
        $$->instr_list.push_back(generateUnconditionalGoto(caseblock_label_list[i+1], curr));
    else
        $$->instr_list.push_back(generateUnconditionalGoto(end,curr));
}
$$->instr_list.push_back(generateLabelInstruction(caseblock_label_list[caseblock_label_list.size()-1]));
}
;
CaseBlockList  :
%empty {$$ = new Node("CaseBlockList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| CaseBlockList CaseBlock{$$ = $1; $$->incrementCount($2);
$$->instr_list = mergeInstructions($$->instr_list, $2->instr_list);
}

;
CaseBlock  :
Case CompoundStatement STMTEND {
$$ = new Node("CaseBlock", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2)->Add($3);
}

;
Case  :
CASE ExpressionOrTypeList COLON{
$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
for(int i=0; i<$2->count;++i){
    $$->instr_list=mergeInstructions($$->instr_list, $2->children[i]->instr_list);
}
}
		| CASE ExpressionOrTypeList ASSGN_OP Expression COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
 semanticError("Unimplemented", true);
}
		| CASE ExpressionOrTypeList DECL Expression COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
semanticError("Unimplemented", true);
}
		| DEFAULT COLON{$$ = new Node("Default", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
}

;
ExpressionOrTypeList  :
ExpressionOrTypeList COMMA ExpressionOrType{$$ = $1 ; $$->incrementCount($3); $$->instr_list = mergeInstructions($$->instr_list, $3->instr_list);}
		| ExpressionOrType{$$ = new Node("ExprTypeList", new BasicType("NOTYPE")); $$->instr_list = $1->instr_list;
        $$->Add($1);
        $$->count = 1;
        }
;
InterfaceDeclaration  :
NewName InterfaceDecl{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
// Here is a function, add to stack

vector<Type*> paramTypes = createParamList($2->children[1]);
vector<string> paramNames = createNameList($2->children[1]);
FuncType* t = new FuncType($2->children[3]->getType(), paramTypes);
ST::interfaceStack[$1->content] = t;

}
	| PAREN_OPEN PackName PAREN_CLOSE{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
		| PackName{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
}


;
InterfaceDecl  :
PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("InterfaceDecl", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
}

;
InterfaceDeclarationList  :
InterfaceDeclaration{$$ = new Node("InterfaceDeclarationList", new BasicType("NOTYPE"));
$$->Add($1);}
		| InterfaceDeclarationList STMTEND InterfaceDeclaration{$$ = $1 ; $$->incrementCount($3);}

;
InterfaceType  :
INTERFACE BLOCK_OPEN InterfaceDeclarationList Ostmtend BLOCK_CLOSE{$$ = new Node("InterfaceType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
}
		| INTERFACE BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("InterfaceType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}

;
FunctionLiteral  :
FunctionLiteralDeclaration CompoundStatement{$$ = new Node("FunctionLiteral", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->setType($1->getType());
}

;
GeneratorLiteral  :
GeneratorLiteralDeclaration CompoundStatement {$$ = new Node("GeneratorLiteral", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->setType($1->getType());
}

;
FunctionLiteralDeclaration  :
FunctionType{$$ = $1 ;}

;
GeneratorLiteralDeclaration  :
GeneratorType{$$ = $1; }

;
KeyVal  :
Expression COLON CompLiteralExpression{$$ = new Node("KeyVal", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
;
KeyValList  :
KeyVal{$$ = new Node("KeyVal declaration", new BasicType("NOTYPE")); $$->Add($1);}
	| BareCompLiteralExpression{$$ = new Node("KeyValList", new BasicType("NOTYPE"));
$$->Add($1);
}
		| KeyValList COMMA KeyVal{$$ = $1; $$->incrementCount($3);}
		| KeyValList COMMA BareCompLiteralExpression{$$ = $1; $$->incrementCount($3);}

;
BareCompLiteralExpression  :
Expression{$$ = new Node("BareCompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("BareCompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
;
CompLiteralExpression  :
Expression{$$ = new Node("CompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("CompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
;
BracedKeyValList  :
%empty {$$ = new Node("BracedKeyValList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| KeyValList OComma{$$ = $1;}

;
TypeNameList  :
TypeName{$$ = new Node("TypeNameList", new BasicType("NOTYPE")) ;}
		| TypeNameList COMMA TypeName{$$ = $1; $$->incrementCount($3);}

;
GenericType  :
Name{$$ = $1;}
		| Name COLON TypeNameList{$$ = new Node("GenericType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
;
GenericTypeList  :
GenericType{$$ = new Node("GenericTypeList", new BasicType("NOTYPE")); $$->Add($1);}
		| GenericTypeList GENERIC_CONCAT GenericType{$$ = $1; $$->incrementCount($3);}

;
OGenericTypeList  :
LT GenericTypeList GT{$$ = new Node("OGenericTypeList", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
}
		| %empty {$$ = new Node("Empty GenericTypeList", new BasicType("NOTYPE"), 0);}
;
PseudoCall  :
PrimaryExpr PAREN_OPEN PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), 0);
$$->Add($1);
$$->Add($2);
$$->Add($3);
/* vector<Type*> types; */ // TODO : why is this here?
vector<FuncType*> cand_list;
if($1->matched.compare("PseudoCall")){
if(!curr->checkEntryFunc($1->content)) {
  cand_list = curr->getFunc($1->content);
} else {
  semanticError("Cannot find function " + $1->content, true);
}
$$->type_child = verifyFunctionType(cand_list, 0);
$$->setType($$->type_child.back());
$$->type_child.pop_back();
/* $$->type_child = ((FuncType*)$$->getType())->GetParamTypes(); */
/*  if($$->type_child.size())  { */
/*      semanticError("Unxpected " + to_string($$->type_child.size()) + " arguments, 0 needed!"); */
/*   } */
vector<Node*> emptyVector;
generateCall($$, $1, emptyVector, curr);
// TODO: below statement seems to be uneeded.
/* $$->setType(((FuncType*)$$->getType())->GetReturnType()); */
} else {
    if($1->getType()->GetTypeClass() != 2){
        semanticError("Return type is not function type");
        exit(1);
    }
    $$->type_child = ((FuncType*)$1->getType())->GetParamTypes();
    $$->setType(((FuncType*)$1->getType())->GetReturnType());
}
vector<Node*> emptyVector;
generateCall($$, $1, emptyVector, curr);
}
| PrimaryExpr PAREN_OPEN ExpressionOrTypeList OComma PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), $3->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
if($1->matched.compare("PseudoCall")){
vector<FuncType*> cand_list;
if(!curr->checkEntryFunc($1->content)) {
  cand_list = curr->getFunc($1->content);
} else {
  semanticError("Cannot find function " + $1->content, true);
}
$$->type_child = verifyFunctionType(cand_list, $3->count);
$$->setType($$->type_child.back());
$$->type_child.pop_back();
if($3->count != $$->type_child.size()) {
  semanticError("Unexpected number of arguments");
}
} else {
    if($1->getType()->GetTypeClass() != 2){
        semanticError("Return type is not function type");
        exit(1);
    }
    $$->type_child = ((FuncType*)$$->getType())->GetParamTypes();
    $$->setType(((FuncType*)$$->getType())->GetReturnType());
    vector<Type*>::iterator it = $$->type_child.begin();
    int i=0;
    for(; it!=$$->type_child.end(); ++it){
        if(!(*(*it) == *$3->children[i++]->getType())){
            semanticError("Mismatched return types");
        }
    }
    $$->setType(((FuncType*)$1->getType())->GetReturnType());
}
 generateCall($$, $1, $3->children, curr);
}
| PrimaryExpr PAREN_OPEN ExpressionOrTypeList VARIADIC OComma PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), $3->count+1, true);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
if($1->matched.compare("PseudoCall")){
vector<FuncType*> cand_list;
if(!curr->checkEntryFunc($1->content)) {
  cand_list = curr->getFunc($1->content);
} else {
  semanticError("Cannot find function " + $1->content, true);
}
$$->type_child = verifyFunctionType(cand_list, 0);
$$->setType($$->type_child.back());
$$->type_child.pop_back();
} else {
    if($1->getType()->GetTypeClass() != 2){
        semanticError("Return type is not function type");
        exit(1);
    }
    FuncType* type = (FuncType*)$1->getType();
    $$->setType(type->GetReturnType());
    $$->type_child = type->GetParamTypes();
}
if($$->type_child[$$->type_child.size() - 1]->GetTypeClass() != 1) {
    semanticError("Variadic only work with basic types") ; // TODO : extend this to compound types, struct types etc
  }

if((($3->count + 1) != $$->type_child.size())
|| ((BasicType*)($$->type_child[$$->type_child.size() - 1]))->variadic)   {
    semanticError("Invalid function call, incorrect number of types");
  }
};

%%
int xgen(vector<Instruction*>, ST*);
Type* TypeForSymbol(char* input){
    // returns only INT for now
    if(strlen(input) > 0)
        return new BasicType("int"); // assuming INT
    else
        return new BasicType("NOTYPE"); // empty statement have no type
}

int main(int argc, char** argv) {
    filename = argv[1];
    FILE* myfile = fopen(filename, "r");
    yyin = myfile;
    do {
        yyparse();
    } while (!feof(yyin));
    vector<ST*>::iterator it;
    for (it = root->children.begin(); it != root->children.end(); it++) {
      ;
    }
    printST(root);
    /* cout << "Struct Info " << (ST::structDefs["person"]->fields).size() << endl; */
    /* cout << "fin" << endl; */
    return xgen(finalInstList, root);
}

void yyerror(const char *s) {
    syntaxError(s);
}


int
xgen(vector<Instruction*> finalInstList, ST* glob)
{
    X86Generator gen(finalInstList, glob);
    cout << gen.Generate();
    return 0;
}

