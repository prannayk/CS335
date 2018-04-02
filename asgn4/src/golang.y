
%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string.h>
#include "helpers.h"
#include "Type.h"
#include <typeinfo>
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
SourceFile{$$ = new Node("StartSymbol", new BasicType("NOTYPE"));
$$->Add($1);$$->PrintJS();cout <<"SourceFile" << endl ;}

;
SourceFile  :
Package Imports DeclarationList{$$ = new Node("SourceFile", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Package"<< " " <<"Imports"<< " " <<"DeclarationList" << endl ;}

;
Package  :
PACKAGE ID STMTEND{$$ = new Node("Package", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"package" << " " << $1<< " " <<"id" << " " << $2<< " " <<"stmtend" << " " << $3 << endl ;}

;
Imports  :
/* Empty Rule */ {$$ = new Node("Imports", new BasicType("NOTYPE"), 0);
$$->Add("");}		| Imports Import STMTEND{$$ = new Node("Imports", new BasicType("NOTYPE"), $1->count + 1);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"Imports"<< " " <<"Import"<< " " <<"stmtend" << " " << $3 << endl ;}

;
Import  :
IMPORT ImportStatement{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"import" << " " << $1<< " " <<"ImportStatement" << endl ;}
		| IMPORT PAREN_OPEN ImportStatementList Ostmtend PAREN_CLOSE{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"import" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"ImportStatementList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| IMPORT PAREN_OPEN PAREN_CLOSE{$$ = new Node("Import", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"import" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}

;
ImportStatement  :
Literal{$$ = $1;}
		| ID Literal{$$ = new Node("ImportStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"id" << " " << $1<< " " <<"Literal" << endl ;}
		| DOT Literal{$$ = new Node("ImportStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"dot" << " " << $1<< " " <<"Literal" << endl ;}

;
ImportStatementList  :
ImportStatement{$$ = new Node("ImportStatement", new BasicType("NOTYPE")); $$->Add($1);}
		| ImportStatementList STMTEND ImportStatement{$$ = $1; $$->incrementCount($3);}

;
Ostmtend  :
/* Empty Rule */ {$$ = new Node("Ostmtend", new BasicType("NOTYPE"), 0);
$$->Add("");}		| STMTEND{$$ = new Node("Ostmtend", new BasicType("NOTYPE"));
$$->Add($1);cout <<"stmtend" << " " << $1 << endl ;}

;
DeclarationList  :
/* Empty Rule */ {$$ = new Node("DeclarationList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| DeclarationList Declaration STMTEND{$$ = $1; $$->incrementCount($2);}

;
Declaration  :
CommonDeclaration{$$ = $1;}
		| FunctionDeclaration{$$ = $1;}
		| GeneratorDeclaration{$$ = $1;}

;
CommonDeclaration  :
VAR VarDeclaration{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"var" << " " << $1<< " " <<"VarDeclaration" << endl ;}
		| VAR PAREN_OPEN VarDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"var" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"VarDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| VAR PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"var" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}
		| CONST ConstDeclaration{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"const" << " " << $1<< " " <<"ConstDeclaration" << endl ;}
		| CONST PAREN_OPEN ConstDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"const" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"ConstDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| CONST PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"const" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}
		| TYPE TypeDeclaration{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"type" << " " << $1<< " " <<"TypeDeclaration" << endl ;}
		| TYPE PAREN_OPEN TypeDeclarationList Ostmtend PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"type" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"TypeDeclarationList"<< " " <<"Ostmtend"<< " " <<"paren_close" << " " << $5 << endl ;}
		| TYPE PAREN_OPEN PAREN_CLOSE{$$ = new Node("CommonDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"type" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"paren_close" << " " << $3 << endl ;}

;
VarDeclaration  :
DeclarationNameList ASSGN_OP ExpressionList{$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
inferListType($1, $3); // : Add symbol table entry creation here
populateST($1, $1, curr);
}
| DeclarationNameList TypeName{$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"DeclarationNameList"<< " " <<"TypeName" << endl;
populateST($1, $2, curr);
}
| DeclarationNameList TypeName ASSGN_OP ExpressionList{$$ = new Node("VarDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"DeclarationNameList"<< " " <<"TypeName"<< " " <<"assgn_op" << " " << $3<< " " <<"ExpressionList" << endl ;
populateST($1, $2, curr);}

;
ConstDeclaration  :
DeclarationNameList ASSGN_OP ExpressionList{$$ = new Node("ConstDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
inferListType($1, $3); // : Add symboltable entry creation here
populateST($1, $1, curr, 1);
}
		| DeclarationNameList TypeName ASSGN_OP ExpressionList{$$ = new Node("ConstDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"DeclarationNameList"<< " " <<"TypeName"<< " " <<"assgn_op" << " " << $3<< " " <<"ExpressionList" << endl ;
populateST($1, $2, curr, 1);}

;
DeclarationNameList  :
DeclarationName{$$ = new Node("Declaration Name List", new BasicType("NOTYPE")); $$->Add($1); }
		| DeclarationNameList COMMA DeclarationName{$$ = $1; $$->incrementCount($3);}

;
DeclarationName  :
ID{$$ = new Node("Declaration Name", new BasicType("NOTYPE")); $$->Add($1);}

;
PointerType  :
STAR TypeName{$$ = new Node("PointerType", new BasicType($2->getType()->GetRepresentation(), false, true));
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
$$->setType(new StructDefinitionType("placeholder", fieldNames, typeList));
}
		| STRUCT OGenericTypeList BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("StructType", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
vector <string> fieldNames;
vector<Type*> typeList;
$$->setType(new StructDefinitionType("placeholder", fieldNames, typeList));
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
$$->setType(new BasicType($2->getType()->GetRepresentation(), false, true));
if ($3->getType() != new BasicType("NOTYPE"))
    $$->content = $3->content;
}
        | PAREN_OPEN STAR Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->setType(new BasicType($3->getType()->GetRepresentation(), false, true));
if ($5->getType() != new BasicType("NOTYPE"))
    $$->content = $5->content;
}
		| STAR PAREN_OPEN Embed PAREN_CLOSE OLiteral{$$ = new Node("StructDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->setType(new BasicType($3->getType()->GetRepresentation(), false, true));
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
		| DotName{$$ = $1;}
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
$$->Add($2);cout <<"TypeDeclarationName"<< " " <<"TypeName" << endl ;}

;
TypeDeclarationName  :
ID{$$ = new Node("TypeDeclarationName", new BasicType("NOTYPE"));
$$->Add($1);cout <<"id" << " " << $1 << endl ;}

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
		| UnaryExpr{ $$ = $1;$$->setType($1->getType()); $$->tmp = $$->content; }

;
OExpression  :
/* Empty Rule */ {$$ = new Node("OExpression", new BasicType("NOTYPE"), 0);
$$->Add("");}		| Expression{$$ = $1;}

;
UnaryExpr  :
STAR UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"star" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| AMPERSAND UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"ampersand" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| ADD UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"add" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| SUB UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"sub" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| NOT_OP UnaryExpr{$$ = new Node("UnaryExpr", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"not_op" << " " << $1<< " " <<"UnaryExpr" << endl ;}
		| PrimaryExpr{$$ = $1;$$->setType($1->getType());}

;
PrimaryExpr  :
PrimaryExprNoParen{$$ = $1;$$->setType($1->getType());}
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
Name{$$ = $1;
$$->addrMode = REGISTER;}
| Literal{$$ = $1;$$->setType($1->getType());$$->addrMode = CONSTANT_VAL;}
| PrimaryExpr DOT ID{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
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
$$->Add($5);cout <<"Warning : Unimplemented runtime feature being used!" << endl;
}  
		| PrimaryExpr SQUARE_OPEN Expression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4); // TODO : handle array access  
}
		| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE")) ; // TODO : slices
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);}
		| PrimaryExpr SQUARE_OPEN OExpression COLON OExpression COLON OExpression SQUARE_CLOSE{$$ = new Node("PrimaryExprNoParen", new BasicType("NOTYPE")); // TODO : slices
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
$$->Add($7);
$$->Add($8);cout <<"PrimaryExpr"<< " " <<"square_open" << " " << $2<< " " <<"OExpression"<< " " <<"colon" << " " << $4<< " " <<"OExpression"<< " " <<"colon" << " " << $6<< " " <<"OExpression"<< " " <<"square_close" << " " << $8 << endl ;}
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
		| PseudoCall{$$ = $1;} // TODO: handle type checking of pseudocall 
            // get type of function return type here

;
NonExpressionType  :
FunctionType{$$ = $1;}
		| GeneratorType{$$ = $1;}
		| OtherType{$$ = $1;}
		| STAR NonExpressionType{$$ = new Node("NonExpressionType", new BasicType($2->getType()->GetRepresentation(),false, true));
$$->Add($1);
$$->Add($2);}

;
OtherType  : 
SQUARE_OPEN OExpression SQUARE_CLOSE TypeName{
if($2->count != 0) {
    $$ = new Node("OtherType", new ArrayType($4->getType(), atoi($2->content.c_str())) );
} else {
    // TODO : slice Type
}
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"square_open" << " " << $1<< " " <<"OExpression"<< " " <<"square_close" << " " << $3<< " " <<"TypeName" << endl ;}
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
ID{$$ = new Node("NewName", new BasicType("NOTYPE")); $$->Add($1); $$->content = $1;}

;
DeclName  :
ID{$$ = $1;}

;
ONewName  :
/* Empty Rule */ {$$ = new Node("Empty New Name", new BasicType("NOTYPE"), 0); $$->Add("");}		
| NewName{$$ = $1;}

;
Name  :
ID %prec NotParen{$$ = new Node("Name", new BasicType("NOTYPE")); $$->Add($1); $$->setType(new BasicType($1));
$$->content = $1; 
}

;
ExpressionList  :
Expression{$$ = new Node("Expression", new BasicType("NOTYPE")); $$->Add($1);}
		| ExpressionList COMMA Expression{$$ = $1; $$->incrementCount($3);}

;
OExpressionList  :
/* Empty Rule */ {$$ = new Node("Empty Expression List", new BasicType("NOTYPE"), 0);}
    | ExpressionList{$$ = $1;}

;
OLiteral  :
/* Empty Rule */ {$$ = new Node("Empty Literal", new BasicType("NOTYPE"), 0);}		
| Literal{$$ = $1; $$->setType($1->getType());}

;
Literal  :
RAW_STRING{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1); $$->setType(new BasicType("str")); $$->content = $1;}
		| INTER_STRING{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("byte")); $$->content = $1;}
		| DECIMAL_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("int")); $$->content = $1;}
		| OCTAL_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("octal")); $$->content = $1;}
		| HEX_LIT{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("hex")); $$->content = $1;}
		| TRUE{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("bool")); $$->content = $1;}
		| FALSE{$$ = new Node("Literal", new BasicType("NOTYPE"));
$$->Add($1);$$->setType(new BasicType("bool")); $$->content = $1;}

;
FunctionDeclaration  :
FUNC OGenericTypeList FunctionHeader FunctionBody{$$ = new Node("FunctionDeclaration", new BasicType("NOTYPE"), $2->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"func" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"FunctionHeader"<< " " <<"FunctionBody" << endl ;

// Do cool functype stuff
if (($3->children).size() == 5) {
  vector<Type*> paramTypes = createParamList($3->children[2]->children[0]);
  FuncType* t = new FuncType($3->children[4]->getType(), paramTypes);
  ST::funcDefs[($3->children[0])->matched] = t;
} else {
  vector<Type*> paramTypes = createParamList($3->children[5]->children[0]);
  FuncType* t = new FuncType($3->children[7]->getType(), paramTypes);
  ST::funcDefs[($3->children[3])->matched] = t;
}

}
;
GeneratorDeclaration  :
GEN OGenericTypeList FunctionHeader FunctionBody{$$ = new Node("GeneratorDeclaration", new BasicType("NOTYPE"), $2->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"gen" << " " << $1<< " " <<"OGenericTypeList"<< " " <<"FunctionHeader"<< " " <<"FunctionBody" << endl ;

// Do cool functype stuff
if (($3->children).size() == 5) {
  vector<Type*> paramTypes = createParamList($3->children[2]->children[0]);
  FuncType* t = new FuncType($3->children[4]->getType(), paramTypes, true);
  ST::funcDefs[($3->children[0])->matched] = t;
} else {
  vector<Type*> paramTypes = createParamList($3->children[5]->children[0]);
  FuncType* t = new FuncType($3->children[7]->getType(), paramTypes, true);
  ST::funcDefs[($3->children[3])->matched] = t;
}
}

;
FunctionHeader  :
ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionHeader", new BasicType("NOTYPE"), $3->count, $3->flag);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);


cout <<"noticeme" <<"id" << " " << $1<< " " <<"paren_open" << " " << $2<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $4<< " " <<"FunctionResult" << endl ;}

		| PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("FunctionHeader", new BasicType("NOTYPE"), $2->count, $2->flag);
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
FunctionType{$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);cout <<"FunctionType" << endl ;}
		| GeneratorType{$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);cout <<"GeneratorType" << endl ;}
		| OtherType{$$ = new Node("ConvType", new BasicType("NOTYPE"));
$$->Add($1);cout <<"OtherType" << endl ;}

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
/* Empty Rule */ {$$ = new Node("FunctionResult", new BasicType("NOTYPE"), 0);
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
$$->Add($1);cout <<"CompoundStatement" << endl ;}

;
OArgumentTypeListOComma  :
/* Empty Rule */ {$$ = new Node("OArgumentTypeListOComma", new BasicType("NOTYPE"), 0);
$$->Add("");}		| ArgumentTypeList OComma{$$ = new Node("OArgumentTypeListOComma", new BasicType("NOTYPE"), $1->count, $1->flag);
$$->Add($1);
$$->Add($2);cout <<"ArgumentTypeList"<< " " <<"OComma" << endl ;}

;
ArgumentTypeList  :
ArgumentType{$$ = new Node("ArgumentType", $1->getType()); $$->Add($1);}
		| ArgumentTypeList COMMA ArgumentType{$$ = $1 ; $$->incrementCount($3);}

;
ArgumentType  :
NameOrType{$$ = $1; $$->count = 1;
//    $$ = new Node() TODO : handle this somehow
}
		| ID NameOrType{$$ = new Node("ArgumentType", $2->getType()); $$->count = 2; 
$$->Add($1);
$$->Add($2);$$->content = $1; }
		| ID VARIADIC{$$ = new Node("ArgumentType", new BasicType("NOTYPE"), 1, true); $$->count = 2;
$$->Add($1);
$$->Add($2);cout <<"id" << " " << $1<< " " <<"variadic" << " " << $2 << endl ;}
		| VARIADIC TypeName{$$ = new Node("ArgumentType", $2->getType(), 1, true); $$->count = 2;
$$->Add($1); // TODO : handling this is unclear
$$->Add($2);cout <<"variadic" << " " << $1<< " " <<"TypeName" << endl ;}
		| VARIADIC{$$ = new Node("ArgumentType", new BasicType("NOTYPE"), 1, true); $$->count = 2;
$$->Add($1);cout <<"variadic" << " " << $1 << endl ; // TODO: handle this, since it opens possibility of no types being defined for the entire list
}

;
NameOrType  :
TypeName{$$ = $1;}

;
OComma  :
COMMA{$$ = new Node("OComma", new BasicType("NOTYPE"));
$$->Add($1);cout <<"comma" << " " << $1 << endl ;}
		| /* Empty Rule */ {$$ = new Node("OComma", new BasicType("NOTYPE"), 0);
$$->Add("");}
;
OSimpleStatement  :
/* Empty Rule */ {$$ = new Node("OSimpleStatement", new BasicType("NOTYPE"), 0);
$$->Add("");}		| SimpleStatement{$$ = $1;}

;
SimpleStatement  :
Expression{$$ = $1; }
		| ExpressionList ASSGN_OP ExpressionList{$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->instr_list = mergeInstructions($1->instr_list, $3->instr_list);
$$->instr_list = mergeInstructions($$->instr_list, generateInstructionsAssignment($1, $3, curr));
}
		| ExpressionList DECL ExpressionList{$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);inferListType($1, $3);
$$->instr_list = mergeInstructions($1->instr_list, $3->instr_list);
$$->instr_list = mergeInstructions($$->instr_list, generateInstructionsAssignment($1, $3, curr));
}
		| Expression INC{$$ = new Node("SimpleStatement", $1->getType());
$$->Add($1);
$$->Add($2);
$$->instr_list = $1->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(INC_OP, $1, curr));
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
}
		| Expression DEC{$$ = new Node("SimpleStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $1->instr_list;
$$->instr_list.push_back(generateUnaryInstruction(DEC_OP, $1, curr));
$$->tmp = getTemp($$);
$$->addrMode = REGISTER;
}

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
BLOCK_CLOSE{$$ = new Node("CompoundStatement", new BasicType("NOTYPE"), $3->count);
$$->Add($1);
$$->Add($3);
$$->Add($5);cout <<"block_open" << " " << $1<< " " <<"StatementList"<< " " <<"block_close" << " " << $5 << endl ;}

;
StatementList  : // TODO  : this is also beginning of a scope, unhandled
Statement{$$ = new Node("Statement", new BasicType("NOTYPE")); $$->Add($1);}
		| StatementList STMTEND Statement{$$ = $1; $$->incrementCount($3); $$->instr_list = mergeInstructions($$->instr_list, $3->instr_list); }

;
Statement  :
/* Empty Rule */ {$$ = new Node("Statement", new BasicType("NOTYPE"), 0);
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
}
		| FALLTHROUGH{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1); //$$->instr_list.push_back(generateFallThroughInstruction()); // TODO : handling unclear of all the following
} 
		| BREAK ONewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);}
		| CONTINUE ONewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"continue" << " " << $1<< " " <<"ONewName" << endl ;}
		| GOTO NewName{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"goto" << " " << $1<< " " <<"NewName" << endl ;}
		| RETURN OExpressionList{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"return" << " " << $1<< " " <<"OExpressionList" << endl ;}
		| YIELD OExpressionList{$$ = new Node("NonDeclarationStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"yield" << " " << $1<< " " <<"OExpressionList" << endl ;}

;
LabelName  :
NewName{$$ = $1;}

;
IfStatement  :
IF IfHeader LoopBody ElseIfList Else{$$ = new Node("IfStatement", new BasicType("NOTYPE"), $3->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->instr_list = $2->instr_list;
for(int i=0; i< $4->count; ++i)
    $$->instr_list = mergeInstructions($$->instr_list,$4->children[i]->children[2]->instr_list);
Instruction* branch_goto = generateUnconditionalGoto(curr);
$$->instr_list.push_back(branch_goto);
string s = (char *)$$->instr_list[$$->instr_list.size() - 1]->getV1();
string s1 = $2->getType()->GetRepresentation(); 
$$->instr_list.push_back(generateLabelInstruction(s1 ));
$$->instr_list = mergeInstructions($$->instr_list, $3->instr_list);
for(int i=0; i< $4->count; ++i){
    $$->instr_list.push_back(generateLabelInstruction($4->children[i]->getType()->GetRepresentation()));
    $$->instr_list = mergeInstructions($$->instr_list,$4->children[i]->children[3]->instr_list);
    $$->instr_list.push_back(branch_goto);
}
$$->instr_list.push_back(generateLabelInstruction(s));
if($5->count > 0)
    $$->instr_list = mergeInstructions($$->instr_list, $5->children[1]->instr_list);
}

;
ElseIf  :
ELSE IF IfHeader LoopBody{$$ = new Node("ElseIf", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);}

;
ElseIfList  :
/* Empty Rule */ {$$ = new Node("Empty ElseIfList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| ElseIfList ElseIf{$$ = $1 ; $$->incrementCount($2);}

;
Else  :
/* Empty Rule */ {$$ = new Node("Else", new BasicType("NOTYPE"), 0);
$$->Add("");}		| ELSE CompoundStatement{$$ = new Node("Else", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list.push_back(generateGotoInstruction($2, curr));
$$->setType(new BasicType((char*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
}

;
LoopBody  :
BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("LoopBody", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);$$->instr_list = $2->instr_list;}

;
IfHeader  :
OSimpleStatement{$$ = new Node("IfHeader", new BasicType("label"));
$$->Add($1);
$$->instr_list = $1->instr_list; 
$$->instr_list.push_back(generateGotoInstruction($1, curr));
$$->setType(new BasicType((char*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
}
		| OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("IfHeader", new BasicType("label"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->instr_list = mergeInstructions($1->instr_list, $3->instr_list); 
$$->instr_list.push_back(generateGotoInstruction($3, curr));
$$->setType(new BasicType((char*)$$->instr_list[$$->instr_list.size()-1]->getV1()));
}

;
ForStatement  :
FOR ForBody{$$ = new Node("ForStatement", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->instr_list = $2->instr_list;
}

;
ForBody  :
ForHeader LoopBody{$$ = new Node("ForBody", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);

}

;
ForHeader  :
OSimpleStatement STMTEND OSimpleStatement STMTEND OSimpleStatement{$$ = new Node("ForHeader", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"OSimpleStatement"<< " " <<"stmtend" << " " << $2<< " " <<"OSimpleStatement"<< " " <<"stmtend" << " " << $4<< " " <<"OSimpleStatement" << endl ;}
		| OSimpleStatement{$$ = $1;}
		| RangeStatement{$$ = $1;}

;
RangeStatement  :
ExpressionList ASSGN_OP RANGE Expression{$$ = new Node("RangeStatement", new BasicType("NOTYPE"), $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"ExpressionList"<< " " <<"assgn_op" << " " << $2<< " " <<"range" << " " << $3<< " " <<"Expression" << endl ;}
		| ExpressionList DECL RANGE Expression{$$ = new Node("RangeStatement", new BasicType("NOTYPE"), $1->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"ExpressionList"<< " " <<"decl" << " " << $2<< " " <<"range" << " " << $3<< " " <<"Expression" << endl ;}
		| RANGE Expression{$$ = new Node("RangeStatement", new BasicType("NOTYPE"), 0);
$$->Add($1);
$$->Add($2);cout <<"range" << " " << $1<< " " <<"Expression" << endl ;}

;
SwitchStatement  :
SWITCH IfHeader BLOCK_OPEN CaseBlockList BLOCK_CLOSE{$$ = new Node("SwitchStatement", new BasicType("NOTYPE"), $4->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"switch" << " " << $1<< " " <<"IfHeader"<< " " <<"block_open" << " " << $3<< " " <<"CaseBlockList"<< " " <<"block_close" << " " << $5 << endl ;}

;
CaseBlockList  :
/* Empty Rule */ {$$ = new Node("CaseBlockList", new BasicType("NOTYPE"), 0);
$$->Add("");}		| CaseBlockList CaseBlock{$$ = $1; $$->incrementCount($2);}

;
CaseBlock  :
Case CompoundStatement STMTEND {$$ = new Node("CaseBlock", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2)->Add($3);cout <<"Case"<< " " <<"CompoundStatement" << $3 << endl ;}

;
Case  :
CASE ExpressionOrTypeList COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"colon" << " " << $3 << endl ;}
		| CASE ExpressionOrTypeList ASSGN_OP Expression COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"assgn_op" << " " << $3<< " " <<"Expression"<< " " <<"colon" << " " << $5 << endl ;}
		| CASE ExpressionOrTypeList DECL Expression COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);cout <<"case" << " " << $1<< " " <<"ExpressionOrTypeList"<< " " <<"decl" << " " << $3<< " " <<"Expression"<< " " <<"colon" << " " << $5 << endl ;}
		| DEFAULT COLON{$$ = new Node("Case", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"default" << " " << $1<< " " <<"colon" << " " << $2 << endl ;}

;
ExpressionOrTypeList  :
ExpressionOrTypeList COMMA ExpressionOrType{$$ = $1 ; $$->incrementCount($3);}
		| ExpressionOrType{$$ = new Node("ExpressionOrTypeList", new BasicType("NOTYPE"));
$$->Add($1);}

;
InterfaceDeclaration  :
NewName InterfaceDecl{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);cout <<"NewName"<< " " <<"InterfaceDecl" << endl ;}
		| PAREN_OPEN PackName PAREN_CLOSE{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"paren_open" << " " << $1<< " " <<"PackName"<< " " <<"paren_close" << " " << $3 << endl ;}
		| PackName{$$ = new Node("InterfaceDeclaration", new BasicType("NOTYPE"));
$$->Add($1);cout <<"PackName" << endl ;}

;
InterfaceDecl  :
PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult{$$ = new Node("InterfaceDecl", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);cout <<"paren_open" << " " << $1<< " " <<"OArgumentTypeListOComma"<< " " <<"paren_close" << " " << $3<< " " <<"FunctionResult" << endl ;}

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
$$->Add($5);cout <<"interface" << " " << $1<< " " <<"block_open" << " " << $2<< " " <<"InterfaceDeclarationList"<< " " <<"Ostmtend"<< " " <<"block_close" << " " << $5 << endl ;}
		| INTERFACE BLOCK_OPEN BLOCK_CLOSE{$$ = new Node("InterfaceType", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"interface" << " " << $1<< " " <<"block_open" << " " << $2<< " " <<"block_close" << " " << $3 << endl ;}

;
FunctionLiteral  :
FunctionLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("FunctionLiteral", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->setType($1->getType());
}

;
GeneratorLiteral  :
GeneratorLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE{$$ = new Node("GeneratorLiteral", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
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
$$->Add($3);cout <<"Expression"<< " " <<"colon" << " " << $2<< " " <<"CompLiteralExpression" << endl ;}

;
KeyValList  :
KeyVal{$$ = new Node("KeyVal declaration", new BasicType("NOTYPE")); $$->Add($1);}
		| BareCompLiteralExpression{$$ = new Node("KeyValList", new BasicType("NOTYPE"));
$$->Add($1);cout <<"BareCompLiteralExpression" << endl ;}
		| KeyValList COMMA KeyVal{$$ = $1; $$->incrementCount($3);}
		| KeyValList COMMA BareCompLiteralExpression{$$ = $1; $$->incrementCount($3);}

;
BareCompLiteralExpression  :
Expression{$$ = new Node("BareCompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);cout <<"Expression" << endl ;}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("BareCompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"block_open" << " " << $1<< " " <<"BracedKeyValList"<< " " <<"block_close" << " " << $3 << endl ;}

;
CompLiteralExpression  :
Expression{$$ = new Node("CompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);cout <<"Expression" << endl ;}
		| BLOCK_OPEN BracedKeyValList BLOCK_CLOSE{$$ = new Node("CompLiteralExpression", new BasicType("NOTYPE"));
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"block_open" << " " << $1<< " " <<"BracedKeyValList"<< " " <<"block_close" << " " << $3 << endl ;}

;
BracedKeyValList  :
/* Empty Rule */ {$$ = new Node("BracedKeyValList", new BasicType("NOTYPE"), 0);
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
$$->Add($3);cout <<"Name"<< " " <<"colon" << " " << $2<< " " <<"TypeNameList" << endl ;}

;
GenericTypeList  :
GenericType{$$ = new Node("GenericTypeList", new BasicType("NOTYPE")); $$->Add($1);}
		| GenericTypeList GENERIC_CONCAT GenericType{$$ = $1; $$->incrementCount($3);}

;
OGenericTypeList  :
LT GenericTypeList GT{$$ = new Node("OGenericTypeList", new BasicType("NOTYPE"), $2->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);cout <<"lt" << " " << $1<< " " <<"GenericTypeList"<< " " <<"gt" << " " << $3 << endl ;}
		| /* Empty Rule */ {$$ = new Node("Empty GenericTypeList", new BasicType("NOTYPE"), 0);}
;
PseudoCall  :
PrimaryExpr PAREN_OPEN PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), 0);
$$->Add($1);
$$->Add($2);
$$->Add($3);
if(curr->checkEntryFunc($1->content))
$$->setType(curr->getFunc($1->content));
$$->type_child = ((FuncType*)$$->getType())->GetParamTypes();
cout<<"Here"<<endl;
if($$->type_child.size())  cout << "Error : expecting " << $$->type_child.size()  <<" arguments, 0 provided!"<<endl;
$$->setType(((FuncType*)$$->getType())->GetReturnType());
}
| PrimaryExpr PAREN_OPEN ExpressionOrTypeList OComma PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), $3->count);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
if(!curr->checkEntryFunc($1->content)) $$->setType(curr->getFunc($1->content));
$$->type_child = ((FuncType*)$$->getType())->GetParamTypes();
if($3->count != $$->type_child.size()) cout << "Unexpected number of arguments" << endl;
}
| PrimaryExpr PAREN_OPEN ExpressionOrTypeList VARIADIC OComma PAREN_CLOSE{$$ = new Node("PseudoCall", new BasicType("NOTYPE"), $3->count+1, true);
$$->Add($1);
$$->Add($2);
$$->Add($3);
$$->Add($4);
$$->Add($5);
$$->Add($6);
if(curr->checkEntryFunc($1->content)) $$->setType(curr->getFunc($1->content));
$$->type_child = ((FuncType*)$$->getType())->GetParamTypes();
if($$->type_child[$$->type_child.size() - 1]->GetTypeClass() != 1) cout << "Variadic only work with basic types" << endl ; // TODO : extend this to compound types, struct types etc
if((($3->count + 1) != $$->type_child.size()) || ((BasicType*)($$->type_child[$$->type_child.size() - 1]))->variadic)   cout<<"Error invalid function call, unknown number of types" << endl;
};

%%

Type* TypeForSymbol(char* input){
    // returns only INT for now
    if(strlen(input) > 0)
        return new BasicType("int"); // assuming INT 
    else
        return new BasicType("NOTYPE"); // empty statement have no type
}

int main(int argc, char** argv) {
	FILE *myfile = fopen(argv[1], "r");
        yyin = myfile;
        do {
            yyparse();
        } while (!feof(yyin));
    cout << "Printing ST" << endl;
    printST(root);
    cout << "There are " << (ST::funcDefs.size()) << " many functions" << endl;
    cout << "fin" << endl;
    return 0;
}

void yyerror(const char *s) {
    printf("ParseError: %s\n", s);
	cout<< "Error on line : "<<global_loc->line << ":" << global_loc->col2 << " to " << global_loc->line << ":" << global_loc->col1 << endl;
    exit(-1);
}

