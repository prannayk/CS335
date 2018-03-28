
%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "helpers.h"
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
%type		<nt>		DeclName
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
SourceFile{$$ = new Node("StartSymbol", NOTYPE);
$$->Add($1);$$->PrintJS();cout <<"SourceFile" << endl ;}

;
SourceFile  :
Package Imports DeclarationList{$$ = new Node("SourceFile", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Package"<< " " <<"Imports"<< " " <<"DeclarationList" << endl ;}

;
Package  :
PACKAGE ID STMTEND{$$ = new Node("Package", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"package" << " " << $1<< " " <<"id" << " " << $2<< " " <<"stmtend" << " " << $3 << endl ;}

;
Imports  :
/* Empty Rule */ {$$ = new Node("Imports", NOTYPE, 0);
$$->Add("");}		| Imports Import STMTEND{$$ = new Node("Imports", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Imports"<< " " <<"Import"<< " " <<"stmtend" << " " << $3 << endl ;}

;
Import  :
IMPORT ImportStatement{$$ = new Node("Import", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"import" << " " << $1<< " " <<"ImportStatement" << endl ;}
		| IMPORT PAREN_OPEN ImportStatementList Ostmtend PAREN_CLOSE{$$ = new Node("Import", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"import" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"ImportStatementList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| IMPORT PAREN_OPEN PAREN_CLOSE{$$ = new Node("Import", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"import" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}

;
ImportStatement  :
Literal{$$ = $1;}
		| ID Literal{$$ = new Node("ImportStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"id" << " " << $1<< " " <<"Literal" << endl ;}
		| DOT Literal{$$ = new Node("ImportStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"dot" << " " << $1<< " " <<"Literal" << endl ;}

;
ImportStatementList  :
ImportStatement{$$ = $1; }
		| ImportStatementList STMTEND ImportStatement{$$ = new Node("ImportStatementList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ImportStatementList"<< " " <<"stmtend" << " " << $2<< " " <<"ImportStatement" << endl ;}

;
Ostmtend  :
/* Empty Rule */ {$$ = new Node("Ostmtend", NOTYPE, 0);
$$->Add("");}		| STMTEND{$$ = new Node("Ostmtend", NOTYPE);
$$->Add($1);cout <<"stmtend" << " " << $1 << endl ;}

;
DeclarationList  :
/* Empty Rule */ {$$ = new Node("DeclarationList", NOTYPE, 0);
$$->Add("");}		| DeclarationList Declaration STMTEND{$$ = new Node("DeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"DeclarationList"<< " " <<"Declaration"<< " " <<"stmtend" << " " << $3 << endl ;}

;
Declaration  :
CommonDeclaration{$$ = $1;}
		| FunctionDeclaration{$$ = $1;}
		| GeneratorDeclaration{$$ = $1;}

;
CommonDeclaration  :
VAR VarDeclaration{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"var" << " " << $1<< " " <<"VarDeclaration" << endl ;}
		| VAR PAREN_OPEN VarDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"var" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"VarDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| VAR PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"var" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}
		| CONST ConstDeclaration{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"const" << " " << $1<< " " <<"ConstDeclaration" << endl ;}
		| CONST PAREN_OPEN ConstDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"const" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"ConstDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| CONST PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"const" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}
		| TYPE TypeDeclaration{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"type" << " " << $1<< " " <<"TypeDeclaration" << endl ;}
		| TYPE PAREN_OPEN TypeDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"type" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"TypeDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| TYPE PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"type" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}

;
VarDeclaration  :
DeclarationNameList ASSGN_OP ExpressionList{$$ = new Node("VarDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"DeclarationNameList"<< " " <<"assgn_op" << " " << $2<< " " <<"ExpressionList" << endl ;}
		| DeclarationNameList TypeName{$$ = new Node("VarDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"DeclarationNameList"<< " " <<"TypeName" << endl;
// TODO: here is where the symboltable is populated (UNCOMMENT)
// I assume that the node 1 has a vector of strings called elements for the symbols of the variables, and typename has its "matched" set as the type string
// vector<string>::iterator it;
// for (it = $1->elements.begin(); it != $1->elements.end(); it++) {
// curr->addEntry(it*, $2->matched);
// }
}
		| DeclarationNameList TypeName ASSGN_OP ExpressionList{$$ = new Node("VarDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"DeclarationNameList"<< " " <<"TypeName"<< " " <<"assgn_op" << " " << $3<< " " <<"ExpressionList" << endl ;}

;
ConstDeclaration  :
DeclarationNameList ASSGN_OP ExpressionList{$$ = new Node("ConstDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"DeclarationNameList"<< " " <<"assgn_op" << " " << $2<< " " <<"ExpressionList" << endl ;}
		| DeclarationNameList TypeName ASSGN_OP ExpressionList{$$ = new Node("ConstDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"DeclarationNameList"<< " " <<"TypeName"<< " " <<"assgn_op" << " " << $3<< " " <<"ExpressionList" << endl ;}

;
DeclarationNameList  :
DeclarationName{$$ = $1; }
		| DeclarationNameList COMMA DeclarationName{$$ = new Node("DeclarationNameList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"DeclarationNameList"<< " " <<"comma" << " " << $2<< " " <<"DeclarationName" << endl ;}

;
DeclarationName  :
ID{$$ = new Node("Declaration Name", NOTYPE); $$->Add($1);}

;
PointerType  :
STAR TypeName{$$ = new Node("PointerType", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"star" << " " << $1<< " " <<"TypeName" << endl ;}

;
StructType  :
STRUCT OGenericTypeList BLOCK_OPEN StructDeclarationList Ostmtend BLOCK_CLOSE{$$ = new Node("StructType", NOTYPE, $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"struct" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"block_open" << " " << $3<< " " <<"StructDeclarationList"<< " " <<"Ostmtend"<< " " <<"block_close" << " " << $6 << endl ;}
		| STRUCT OGenericTypeList BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("StructType", NOTYPE, $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"struct" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"block_open" << " " << $3<< " " <<"block_close" << " " << $4 << endl ;}

;
StructDeclarationList  :
StructDeclaration{$$ = $1;}
		| StructDeclarationList STMTEND StructDeclaration{$$ = new Node("StructDeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"StructDeclarationList"<< " " <<"stmtend" << " " << $2<< " " <<"StructDeclaration" << endl ;}

;
StructDeclaration  :
NewNameList TypeName OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"NewNameList"<< " " <<"TypeName"<< " " <<"OLiteral" << endl ;}
		| Embed OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"Embed"<< " " <<"OLiteral" << endl ;}
		| PAREN_OPEN Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"paren_open" << " " << $1<< " " <<"Embed"<< " " <<"paren_close" << " " << $3<< " " <<"OLiteral" << endl ;}
		| STAR Embed OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"star" << " " << $1<< " " <<"Embed"<< " " <<"OLiteral" << endl ;}
		| PAREN_OPEN STAR Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"paren_open" << " " << $1<< " " <<"star" << " " << $2<< " " <<"Embed"<< " " <<"paren_close" << " " << $4<< " " <<"OLiteral" << endl ;}
		| STAR PAREN_OPEN Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"star" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"Embed"<< " " <<"paren_close" << " " << $4<< " " <<"OLiteral" << endl ;}

;
Embed  :
PackName{$$ = $1;}

;
PackName  :
ID DOT ID{$$ = new Node("PackName", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"id" << " " << $1<< " " <<"dot" << " " << $2<< " " <<"id" << " " << $3 << endl ;}
		| ID{$$ = new Node("PackName", NOTYPE); $$->Add($1);}

;
NewNameList  :
NewName{$$ = $1;}
		| NewNameList COMMA NewName{$$ = new Node("NewNameList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"NewNameList"<< " " <<"comma" << " " << $2<< " " <<"NewName" << endl ;}

;
TypeName  :
FunctionType{$$ = $1;}
		| PointerType{$$ = $1;}
		| OtherType{$$ = $1;}
		| DotName{$$ = $1;}
		| PAREN_OPEN TypeName PAREN_CLOSE{$$ = $2;}

;
VarDeclarationList  :
VarDeclarationList STMTEND VarDeclaration{$$ = new Node("VarDeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"VarDeclarationList"<< " " <<"stmtend" << " " << $2<< " " <<"VarDeclaration" << endl ;}
		| VarDeclaration{$$ = $1;}

;
ConstDeclarationList  :
ConstDeclaration{$$ = $1;}
		| ConstDeclarationList STMTEND ConstDeclaration{$$ = new Node("ConstDeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ConstDeclarationList"<< " " <<"stmtend" << " " << $2<< " " <<"ConstDeclaration" << endl ;}

;
TypeDeclaration  :
TypeDeclarationName TypeName{$$ = new Node("TypeDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"TypeDeclarationName"<< " " <<"TypeName" << endl ;}

;
TypeDeclarationName  :
ID{$$ = new Node("TypeDeclarationName", NOTYPE);
$$->Add($1);cout <<"id" << " " << $1 << endl ;}

;
TypeDeclarationList  :
TypeDeclaration{$$ = $1;}
		| TypeDeclarationList STMTEND TypeDeclaration{$$ = new Node("TypeDeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"TypeDeclarationList"<< " " <<"stmtend" << " " << $2<< " " <<"TypeDeclaration" << endl ;}

;
Expression  :
Expression STAR Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"star" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression DIV Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"div" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression MOD Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"mod" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression LS Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"ls" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression RS Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"rs" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression AMPERSAND Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"ampersand" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression NOT_AND Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"not_and" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression ADD Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"add" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression SUB Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"sub" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression BIT_OR Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"bit_or" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression CARET Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"caret" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression AND Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"and" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression OR Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"or" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression EQ Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"eq" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression NE Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"ne" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression GE Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"ge" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression GT Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"gt" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression LE Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"le" << " " << $2<< " " <<"Expression" << endl ;}
		| Expression LT Expression{$$ = new Node("Expression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"lt" << " " << $2<< " " <<"Expression" << endl ;}
		| UnaryExpr{ $$ = $1; }

;
OExpression  :
/* Empty Rule */ {$$ = new Node("OExpression", NOTYPE, 0);
$$->Add("");}		| Expression{$$ = new Node("OExpression", NOTYPE);
$$->Add($1);cout <<"Expression" << endl ;}

;
UnaryExpr  :
STAR UnaryExpr{$$ = new Node("UnaryExpr", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"star" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| AMPERSAND UnaryExpr{$$ = new Node("UnaryExpr", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"ampersand" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| ADD UnaryExpr{$$ = new Node("UnaryExpr", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"add" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| SUB UnaryExpr{$$ = new Node("UnaryExpr", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"sub" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| NOT_OP UnaryExpr{$$ = new Node("UnaryExpr", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"not_op" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| PrimaryExpr{$$ = $1;}

;
PrimaryExpr  :
PrimaryExprNoParen{$$ = $1;}
		| PAREN_OPEN ExpressionOrType PAREN_CLOSE{$$ = $2; }

;
ExpressionOrType  :
Expression{$$ = $1;}
		| NonExpressionType{$$ = $1;}

;
DotName  :
Name{$$ = $1;}
		| Name DOT ID{$$ = new Node("DotName", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Name"<< " " <<"dot" << " " << $2<< " " <<"id" << " " << $3 << endl ;}

;
PrimaryExprNoParen  :
Name{$$ = $1;}
		| Literal{$$ = $1;}
		| PrimaryExpr DOT ID{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"PrimaryExpr"<< " " <<"dot" << " " << $2<< " " <<"id" << " " << $3 << endl ;}
		| PrimaryExpr DOT PAREN_OPEN ExpressionOrType PAREN_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"PrimaryExpr"<< " " <<"dot" << " " << $2<< " " <<"paren_open" << " " << $3<< " " <<"ExpressionOrType"<< " " <<"paren_close" << " " << $5 << endl ;}
		| PrimaryExpr DOT PAREN_OPEN TYPE PAREN_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"PrimaryExpr"<< " " <<"dot" << " " << $2<< " " <<"paren_open" << " " << $3<< " " <<"type" << " " << $4<< " " <<"paren_close" << " " << $5 << endl ;}
		| PrimaryExpr SQUARE_OPEN Expression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"PrimaryExpr"<< " " <<"square_open" << " " << $2<< " " <<"Expression"<< " " <<"square_close" << " " << $4 << endl ;}
		| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"PrimaryExpr"<< " " <<"square_open" << " " << $2<< " " <<"OExpression"<< " " <<"colon" << " " << $4<< " " <<"OExpression"<< " " <<"square_close" << " " << $6 << endl ;}
		| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
$$->Add($7);
$$->Add($8);cout <<"PrimaryExpr"<< " " <<"square_open" << " " << $2<< " " <<"OExpression"<< " " <<"colon" << " " << $4<< " " <<"OExpression"<< " " <<"colon" << " " << $6<< " " <<"OExpression"<< " " <<"square_close" << " " << $8 << endl ;}
		| ConvType AS PAREN_OPEN Expression OComma PAREN_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"ConvType"<< " " <<"as" << " " << $2<< " " <<"paren_open" << " " << $3<< " " <<"Expression"<< " " <<"OComma"<< " " <<"paren_close" << " " << $6 << endl ;}
		| CompType BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"CompType"<< " " <<"block_open" << " " << $2<< " " <<"BracedKeyValList"<< " " <<"block_close" << " " << $4 << endl ;}
		| PrimaryExprNoParen SQ_PIPE_OPEN BracedKeyValList SQ_PIPE_CLOSE{$$ = new Node("PrimaryExprNoParen", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"PrimaryExprNoParen"<< " " <<"sq_pipe_open" << " " << $2<< " " <<"BracedKeyValList"<< " " <<"sq_pipe_close" << " " << $4 << endl ;}
		| FunctionLiteral{$$ = $1;}
		| GeneratorLiteral{$$ = $1;}
		| PseudoCall{$$ = $1;}

;
NonExpressionType  :
FunctionType{$$ = $1;}
		| GeneratorType{$$ = $1;}
		| OtherType{$$ = $1;}
		| STAR NonExpressionType{$$ = new Node("NonExpressionType", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"star" << " " << $1<< " " <<"NonExpressionType" << endl ;}

;
OtherType  :
SQUARE_OPEN OExpression SQUARE_CLOSE TypeName{$$ = new Node("OtherType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"square_open" << " " << $1<< " " <<"OExpression"<< " " <<"square_close" << " " << $3<< " " <<"TypeName" << endl ;}
		| SQUARE_OPEN VARIADIC SQUARE_CLOSE TypeName{$$ = new Node("OtherType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"square_open" << " " << $1<< " " <<"variadic" << " " << $2<< " " <<"square_close" << " " << $3<< " " <<"TypeName" << endl ;}
		| StructType{$$ = $1;}
		| InterfaceType{$$ = $1;}

;
NewName  :
ID{$$ = new Node("NewName", NOTYPE); $$->Add($1);}

;
DeclName  :
ID{$$ = $1;}

;
ONewName  :
/* Empty Rule */ {$$ = new Node("Empty New Name", NOTYPE, 0); $$->Add("");}		
| NewName{$$ = $1;}

;
Name  :
ID %prec NotParen{$$ = new Node("Name", NOTYPE); $$->Add($1);}

;
ExpressionList  :
Expression{$$ = $1;}
		| ExpressionList COMMA Expression{$$ = new Node("ExpressionList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ExpressionList"<< " " <<"comma" << " " << $2<< " " <<"Expression" << endl ;}

;
OExpressionList  :
/* Empty Rule */ {$$ = new Node("Empty Expression List", NOTYPE, 0);}
    | ExpressionList{$$ = $1;}

;
OLiteral  :
/* Empty Rule */ {$$ = new Node("Empty Literal", NOTYPE, 0);}		
| Literal{$$ = $1;}

;
Literal  :
RAW_STRING{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"raw_string" << " " << $1 << endl ;}
		| INTER_STRING{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"inter_string" << " " << $1 << endl ;}
		| DECIMAL_LIT{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"decimal_lit" << " " << $1 << endl ;}
		| OCTAL_LIT{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"octal_lit" << " " << $1 << endl ;}
		| HEX_LIT{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"hex_lit" << " " << $1 << endl ;}
		| TRUE{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"true" << " " << $1 << endl ;}
		| FALSE{$$ = new Node("Literal", NOTYPE);
$$->Add($1);cout <<"false" << " " << $1 << endl ;}

;
FunctionDeclaration  :
FUNC OGenericTypeList FunctionHeader FunctionBody{$$ = new Node("FunctionDeclaration", NOTYPE, $2->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"func" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"FunctionHeader"<< " " <<"FunctionBody" << endl ;}

;
GeneratorDeclaration  :
GEN OGenericTypeList FunctionHeader FunctionBody{$$ = new Node("GeneratorDeclaration", NOTYPE, $2->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"gen" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"FunctionHeader"<< " " <<"FunctionBody" << endl ;}

;
FunctionHeader  :
ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionHeader", NOTYPE, $3->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"id" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $4<< " " <<"FunctionResult" << endl ;}
		| PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionHeader", NOTYPE, $2->count, $2->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
$$->Add($7);
$$->Add($8);cout <<"paren_open" << " " << $1<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $3<< " " <<"id" << " " << $4<< " " <<"paren_open" << " " << $5<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $7<< " " <<"FunctionResult" << endl ;}

;
ConvType  :
FunctionType{$$ = new Node("ConvType", NOTYPE);
$$->Add($1);cout <<"FunctionType" << endl ;}
		| GeneratorType{$$ = new Node("ConvType", NOTYPE);
$$->Add($1);cout <<"GeneratorType" << endl ;}
		| OtherType{$$ = new Node("ConvType", NOTYPE);
$$->Add($1);cout <<"OtherType" << endl ;}

;
CompType  :
OtherType{$$ = new Node("CompType", NOTYPE);
$$->Add($1);cout <<"OtherType" << endl ;}

;
FunctionType  :
FUNC OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"func" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"paren_open" << " " << $3<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $5<< " " <<"FunctionResult" << endl ;}

;
GeneratorType  :
GEN OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("GeneratorType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"gen" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"paren_open" << " " << $3<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $5<< " " <<"FunctionResult" << endl ;}

;
FunctionResult  :
/* Empty Rule */ {$$ = new Node("FunctionResult", NOTYPE, 0);
$$->Add("");}		| FunctionReturnType{$$ = new Node("FunctionResult", NOTYPE);
$$->Add($1);cout <<"FunctionReturnType" << endl ;}
		| PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE{$$ = new Node("FunctionResult", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"paren_open" << " " << $1<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $3 << endl ;}

;
FunctionReturnType  :
FunctionType{$$ = new Node("FunctionReturnType", NOTYPE);
$$->Add($1);cout <<"FunctionType" << endl ;}
		| GeneratorType{$$ = new Node("FunctionReturnType", NOTYPE);
$$->Add($1);cout <<"GeneratorType" << endl ;}
		| OtherType{$$ = new Node("FunctionReturnType", NOTYPE);
$$->Add($1);cout <<"OtherType" << endl ;}
		| DotName{$$ = new Node("FunctionReturnType", NOTYPE);
$$->Add($1);cout <<"DotName" << endl ;}

;
FunctionBody  :
CompoundStatement{$$ = new Node("FunctionBody", NOTYPE);
$$->Add($1);cout <<"CompoundStatement" << endl ;}

;
OArgumentTypeListOComma  :
/* Empty Rule */ {$$ = new Node("OArgumentTypeListOComma", NOTYPE, 0);
$$->Add("");}		| ArgumentTypeList OComma{$$ = new Node("OArgumentTypeListOComma", NOTYPE, $1->count, $1->flag);
$$->Add($1);
$$->Add($2);cout <<"ArgumentTypeList"<< " " <<"OComma" << endl ;}

;
ArgumentTypeList  :
ArgumentType{$$ = $1;}
		| ArgumentTypeList COMMA ArgumentType{$$ = new Node("ArgumentTypeList", NOTYPE, $1->count + 1, $3->flag || $1->flag);
if($3->flag && $1->flag){ /* error stmt */ } 
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ArgumentTypeList"<< " " <<"comma" << " " << $2<< " " <<"ArgumentType" << endl ;}

;
ArgumentType  :
NameOrType{$$ = $1;}
		| ID NameOrType{$$ = new Node("ArgumentType", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"id" << " " << $1<< " " <<"NameOrType" << endl ;}
		| ID VARIADIC{$$ = new Node("ArgumentType", NOTYPE, 1, true);
$$->Add($1);
$$->Add($2);cout <<"id" << " " << $1<< " " <<"variadic" << " " << $2 << endl ;}
		| VARIADIC TypeName{$$ = new Node("ArgumentType", NOTYPE, 1, true);
$$->Add($1);
$$->Add($2);cout <<"variadic" << " " << $1<< " " <<"TypeName" << endl ;}
		| VARIADIC{$$ = new Node("ArgumentType", NOTYPE, 1, true);
$$->Add($1);cout <<"variadic" << " " << $1 << endl ;}

;
NameOrType  :
TypeName{$$ = $1;}

;
OComma  :
COMMA{$$ = new Node("OComma", NOTYPE);
$$->Add($1);cout <<"comma" << " " << $1 << endl ;}
		| /* Empty Rule */ {$$ = new Node("OComma", NOTYPE, 0);
$$->Add("");}
;
OSimpleStatement  :
/* Empty Rule */ {$$ = new Node("OSimpleStatement", NOTYPE, 0);
$$->Add("");}		| SimpleStatement{$$ = new Node("OSimpleStatement", NOTYPE);
$$->Add($1);cout <<"SimpleStatement" << endl ;}

;
SimpleStatement  :
Expression{$$ = new Node("SimpleStatement", NOTYPE);
$$->Add($1);cout <<"Expression" << endl ;}
		| ExpressionList ASSGN_OP ExpressionList{$$ = new Node("SimpleStatement", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ExpressionList"<< " " <<"assgn_op" << " " << $2<< " " <<"ExpressionList" << endl ;}
		| ExpressionList DECL ExpressionList{$$ = new Node("SimpleStatement", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ExpressionList"<< " " <<"decl" << " " << $2<< " " <<"ExpressionList" << endl ;}
		| Expression INC{$$ = new Node("SimpleStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"Expression"<< " " <<"inc" << " " << $2 << endl ;}
		| Expression DEC{$$ = new Node("SimpleStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"Expression"<< " " <<"dec" << " " << $2 << endl ;}

;
CompoundStatement  :
BLOCK_OPEN {
  // This is when a new scope starts
  ST* t = new ST(curr->depth + 1, curr);
  curr->addChild(t);
  curr = t;
}
StatementList {
  // This is where stuff ends
  curr = curr->parent;
} 
BLOCK_CLOSE{$$ = new Node("CompoundStatement", NOTYPE, $3->count);
$$->Add($1);
$$->Add($3);
$$->Add($5);cout <<"block_open" << " " << $1<< " " <<"StatementList"<< " " <<"block_close" << " " << $5 << endl ;}

;
StatementList  :
Statement{$$ = $1;}
		| StatementList STMTEND Statement{$$ = new Node("StatementList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"StatementList"<< " " <<"stmtend" << " " << $2<< " " <<"Statement" << endl ;}

;
Statement  :
/* Empty Rule */ {$$ = new Node("Statement", NOTYPE, 0);
$$->Add("");}		| CompoundStatement{$$ = $1;}
		| CommonDeclaration{$$ = $1;}
		| NonDeclarationStatement{$$ = $1;}

;
NonDeclarationStatement  :
SimpleStatement{$$ = $1;}
		| IfStatement{$$ = $1;}
		| ForStatement{$$ = $1;}
		| SwitchStatement{$$ = $1;}
		| LabelName COLON Statement{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"LabelName"<< " " <<"colon" << " " << $2<< " " <<"Statement" << endl ;}
		| FALLTHROUGH{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);cout <<"fallthrough" << " " << $1 << endl ;}
		| BREAK ONewName{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"break" << " " << $1<< " " <<"ONewName" << endl ;}
		| CONTINUE ONewName{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"continue" << " " << $1<< " " <<"ONewName" << endl ;}
		| GOTO NewName{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"goto" << " " << $1<< " " <<"NewName" << endl ;}
		| RETURN OExpressionList{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"return" << " " << $1<< " " <<"OExpressionList" << endl ;}
		| YIELD OExpressionList{$$ = new Node("NonDeclarationStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"yield" << " " << $1<< " " <<"OExpressionList" << endl ;}

;
LabelName  :
NewName{$$ = $1;}

;
IfStatement  :
IF IfHeader LoopBody ElseIfList Else{$$ = new Node("IfStatement", NOTYPE, $3->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"if" << " " << $1<< " " <<"IfHeader"<< " " <<"LoopBody"<< " " <<"ElseIfList"<< " " <<"Else" << endl ;}

;
ElseIf  :
ELSE IF IfHeader LoopBody{$$ = new Node("ElseIf", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"else" << " " << $1<< " " <<"if" << " " << $2<< " " <<"IfHeader"<< " " <<"LoopBody" << endl ;}

;
ElseIfList  :
/* Empty Rule */ {$$ = new Node("Empty ElseIfList", NOTYPE, 0);
$$->Add("");}		| ElseIfList ElseIf{$$ = new Node("ElseIfList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);cout <<"ElseIfList"<< " " <<"ElseIf" << endl ;}

;
Else  :
/* Empty Rule */ {$$ = new Node("Else", NOTYPE, 0);
$$->Add("");}		| ELSE CompoundStatement{$$ = new Node("Else", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"else" << " " << $1<< " " <<"CompoundStatement" << endl ;}

;
LoopBody  :
BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("LoopBody", NOTYPE, $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"block_open" << " " << $1<< " " <<"StatementList"<< " " <<"block_close" << " " << $3 << endl ;}

;
IfHeader  :
OSimpleStatement{$$ = $1;}
		| OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("IfHeader", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"OSimpleStatement"<< " " <<"stmtend" << " " << $2<< " " <<"OSimpleStatement" << endl ;}

;
ForStatement  :
FOR ForBody{$$ = new Node("ForStatement", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"for" << " " << $1<< " " <<"ForBody" << endl ;}

;
ForBody  :
ForHeader LoopBody{$$ = new Node("ForBody", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"ForHeader"<< " " <<"LoopBody" << endl ;}

;
ForHeader  :
OSimpleStatement STMTEND OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("ForHeader", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"OSimpleStatement"<< " " <<"stmtend" << " " << $2<< " " <<"OSimpleStatement"<< " " <<"stmtend" << " " << $4<< " " <<"OSimpleStatement" << endl ;}
		| OSimpleStatement{$$ = $1;}
		| RangeStatement{$$ = $1;}

;
RangeStatement  :
ExpressionList ASSGN_OP RANGE Expression{$$ = new Node("RangeStatement", NOTYPE, $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"ExpressionList"<< " " <<"assgn_op" << " " << $2<< " " <<"range" << " " << $3<< " " <<"Expression" << endl ;}
		| ExpressionList DECL RANGE Expression{$$ = new Node("RangeStatement", NOTYPE, $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"ExpressionList"<< " " <<"decl" << " " << $2<< " " <<"range" << " " << $3<< " " <<"Expression" << endl ;}
		| RANGE Expression{$$ = new Node("RangeStatement", NOTYPE, 0);
$$->Add($1);
$$->Add($2);cout <<"range" << " " << $1<< " " <<"Expression" << endl ;}

;
SwitchStatement  :
SWITCH IfHeader BLOCK_OPEN CaseBlockList BLOCK_CLOSE{$$ = new Node("SwitchStatement", NOTYPE, $4->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"switch" << " " << $1<< " " <<"IfHeader"<< " " <<"block_open" << " " << $3<< " " <<"CaseBlockList"<< " " <<"block_close" << " " << $5 << endl ;}

;
CaseBlockList  :
/* Empty Rule */ {$$ = new Node("CaseBlockList", NOTYPE, 0);
$$->Add("");}		| CaseBlockList CaseBlock{$$ = new Node("CaseBlockList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);cout <<"CaseBlockList"<< " " <<"CaseBlock" << endl ;}

;
CaseBlock  :
Case CompoundStatement STMTEND {$$ = new Node("CaseBlock", NOTYPE);
$$->Add($1);
$$->Add($2)->Add($3);cout <<"Case"<< " " <<"CompoundStatement" << $3 << endl ;}

;
Case  :
CASE ExpressionOrTypeList COLON{$$ = new Node("Case", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"colon" << " " << $3 << endl ;}
		| CASE ExpressionOrTypeList ASSGN_OP Expression COLON{$$ = new Node("Case", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"assgn_op" << " " << $3<< " " <<"Expression"<< " " <<"colon" << " " << $5 << endl ;}
		| CASE ExpressionOrTypeList DECL Expression COLON{$$ = new Node("Case", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"decl" << " " << $3<< " " <<"Expression"<< " " <<"colon" << " " << $5 << endl ;}
		| DEFAULT COLON{$$ = new Node("Case", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"default" << " " << $1<< " " <<"colon" << " " << $2 << endl ;}

;
ExpressionOrTypeList  :
ExpressionOrTypeList COMMA ExpressionOrType{$$ = new Node("ExpressionOrTypeList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"ExpressionOrTypeList"<< " " <<"comma" << " " << $2<< " " <<"ExpressionOrType" << endl ;}
		| ExpressionOrType{$$ = new Node("ExpressionOrTypeList", NOTYPE);
$$->Add($1);cout <<"ExpressionOrType" << endl ;}

;
InterfaceDeclaration  :
NewName InterfaceDecl{$$ = new Node("InterfaceDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);cout <<"NewName"<< " " <<"InterfaceDecl" << endl ;}
		| PAREN_OPEN PackName PAREN_CLOSE{$$ = new Node("InterfaceDeclaration", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"paren_open" << " " << $1<< " " <<"PackName"<< " " <<"paren_close" << " " << $3 << endl ;}
		| PackName{$$ = new Node("InterfaceDeclaration", NOTYPE);
$$->Add($1);cout <<"PackName" << endl ;}

;
InterfaceDecl  :
PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("InterfaceDecl", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"paren_open" << " " << $1<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $3<< " " <<"FunctionResult" << endl ;}

;
InterfaceDeclarationList  :
InterfaceDeclaration{$$ = new Node("InterfaceDeclarationList", NOTYPE);
$$->Add($1);cout <<"InterfaceDeclaration" << endl ;}
		| InterfaceDeclarationList STMTEND InterfaceDeclaration{$$ = new Node("InterfaceDeclarationList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"InterfaceDeclarationList"<< " " <<"stmtend" << " " << $2<< " " <<"InterfaceDeclaration" << endl ;}

;
InterfaceType  :
INTERFACE BLOCK_OPEN InterfaceDeclarationList Ostmtend BLOCK_CLOSE{$$ = new Node("InterfaceType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"interface" << " " << $1<< " " <<"block_open" << " " << $2<< " " <<"InterfaceDeclarationList"<< " " <<"Ostmtend"<< " " <<"block_close" << " " << $5 << endl ;}
		| INTERFACE BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("InterfaceType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"interface" << " " << $1<< " " <<"block_open" << " " << $2<< " " <<"block_close" << " " << $3 << endl ;}

;
FunctionLiteral  :
FunctionLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("FunctionLiteral", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"FunctionLiteralDeclaration"<< " " <<"block_open" << " " << $2<< " " <<"StatementList"<< " " <<"block_close" << " " << $4 << endl ;}

;
GeneratorLiteral  :
GeneratorLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("GeneratorLiteral", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"GeneratorLiteralDeclaration"<< " " <<"block_open" << " " << $2<< " " <<"StatementList"<< " " <<"block_close" << " " << $4 << endl ;}

;
FunctionLiteralDeclaration  :
FunctionType{$$ = new Node("FunctionLiteralDeclaration", NOTYPE);
$$->Add($1);cout <<"FunctionType" << endl ;}

;
GeneratorLiteralDeclaration  :
GeneratorType{$$ = new Node("GeneratorLiteralDeclaration", NOTYPE);
$$->Add($1);cout <<"GeneratorType" << endl ;}

;
KeyVal  :
Expression COLON CompLiteralExpression{$$ = new Node("KeyVal", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Expression"<< " " <<"colon" << " " << $2<< " " <<"CompLiteralExpression" << endl ;}

;
KeyValList  :
KeyVal{$$ = $1;}
		| BareCompLiteralExpression{$$ = new Node("KeyValList", NOTYPE);
$$->Add($1);cout <<"BareCompLiteralExpression" << endl ;}
		| KeyValList COMMA KeyVal{$$ = new Node("KeyValList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"KeyValList"<< " " <<"comma" << " " << $2<< " " <<"KeyVal" << endl ;}
		| KeyValList COMMA BareCompLiteralExpression{$$ = new Node("KeyValList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"KeyValList"<< " " <<"comma" << " " << $2<< " " <<"BareCompLiteralExpression" << endl ;}

;
BareCompLiteralExpression  :
Expression{$$ = new Node("BareCompLiteralExpression", NOTYPE);
$$->Add($1);cout <<"Expression" << endl ;}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("BareCompLiteralExpression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"block_open" << " " << $1<< " " <<"BracedKeyValList"<< " " <<"block_close" << " " << $3 << endl ;}

;
CompLiteralExpression  :
Expression{$$ = new Node("CompLiteralExpression", NOTYPE);
$$->Add($1);cout <<"Expression" << endl ;}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("CompLiteralExpression", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"block_open" << " " << $1<< " " <<"BracedKeyValList"<< " " <<"block_close" << " " << $3 << endl ;}

;
BracedKeyValList  :
/* Empty Rule */ {$$ = new Node("BracedKeyValList", NOTYPE, 0);
$$->Add("");}		| KeyValList OComma{$$ = new Node("BracedKeyValList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);cout <<"KeyValList"<< " " <<"OComma" << endl ;}

;
TypeNameList  :
TypeName{$$ = $1 ;}
		| TypeNameList COMMA TypeName{$$ = new Node("TypeNameList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"TypeNameList"<< " " <<"comma" << " " << $2<< " " <<"TypeName" << endl ;}

;
GenericType  :
Name{$$ = $1;}
		| Name COLON TypeNameList{$$ = new Node("GenericType", NOTYPE);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Name"<< " " <<"colon" << " " << $2<< " " <<"TypeNameList" << endl ;}

;
GenericTypeList  :
GenericType{$$ = $1;}
		| GenericTypeList GENERIC_CONCAT GenericType{$$ = new Node("GenericTypeList", NOTYPE, $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"GenericTypeList"<< " " <<"generic_concat" << " " << $2<< " " <<"GenericType" << endl ;}

;
OGenericTypeList  :
LT GenericTypeList GT{$$ = new Node("OGenericTypeList", NOTYPE, $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"lt" << " " << $1<< " " <<"GenericTypeList"<< " " <<"gt" << " " << $3 << endl ;}
		| /* Empty Rule */ {$$ = new Node("Empty GenericTypeList", NOTYPE, 0);}
;
PseudoCall  :
PrimaryExpr PAREN_OPEN PAREN_CLOSE{$$ = new Node("PseudoCall", NOTYPE, 0);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"PrimaryExpr"<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}
		| PrimaryExpr PAREN_OPEN ExpressionOrTypeList OComma PAREN_CLOSE{$$ = new Node("PseudoCall", NOTYPE, $3->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"PrimaryExpr"<< " " <<"paren_open" << " " << $2<< " " <<"ExpressionOrTypeList"<< " " <<"OComma"<< " " <<"paren_close" << " " << $5 << endl ;}
		| PrimaryExpr PAREN_OPEN ExpressionOrTypeList VARIADIC OComma PAREN_CLOSE{$$ = new Node("PseudoCall", NOTYPE, $3->count+1, true);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);cout <<"PrimaryExpr"<< " " <<"paren_open" << " " << $2<< " " <<"ExpressionOrTypeList"<< " " <<"variadic" << " " << $4<< " " <<"OComma"<< " " <<"paren_close" << " " << $6 << endl ;}

;

%%

int main(int argc, char** argv) {
	FILE *myfile = fopen(argv[1], "r");
        yyin = myfile;
        do {
            yyparse();
        } while (!feof(yyin));
    cout << curr->children.size() << endl;
    cout << "fin \n";
    return 0;
}

void yyerror(const char *s) {
    printf("ParseError: %s\n", s);
	cout<<global_loc->line << endl;
    exit(-1);
}

