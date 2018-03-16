StartSymbol:
    SourceFile

SourceFile:
    Package Imports DeclarationList

Package:
    PACKAGE ID STMTEND

Imports:
    %
    Imports Import STMTEND

Import:
    IMPORT ImportStatement
    IMPORT PAREN_OPEN ImportStatementList Ostmtend PAREN_CLOSE
    IMPORT PAREN_OPEN PAREN_CLOSE

ImportStatement:
    Literal
    ID Literal
    DOT Literal

ImportStatementList:
    ImportStatement
    ImportStatementList STMTEND ImportStatement

Ostmtend:
    %
    STMTEND

DeclarationList:
    %
    DeclarationList Declaration STMTEND

Declaration:
    CommonDeclaration
    FunctionDeclaration
    GeneratorDeclaration

CommonDeclaration:
    VAR VarDeclaration
    VAR PAREN_OPEN VarDeclarationList Ostmtend PAREN_CLOSE
    VAR PAREN_OPEN PAREN_CLOSE
    CONST ConstDeclaration
    CONST PAREN_OPEN ConstDeclarationList Ostmtend PAREN_CLOSE
    CONST PAREN_OPEN PAREN_CLOSE
    TYPE TypeDeclaration
    TYPE PAREN_OPEN TypeDeclarationList Ostmtend PAREN_CLOSE
    TYPE PAREN_OPEN PAREN_CLOSE

VarDeclaration:
    DeclarationNameList ASSGN_OP ExpressionList
    DeclarationNameList TypeName
    DeclarationNameList TypeName ASSGN_OP ExpressionList

ConstDeclaration:
    DeclarationNameList ASSGN_OP ExpressionList
    DeclarationNameList TypeName ASSGN_OP ExpressionList

DeclarationNameList:
    DeclarationName
    DeclarationNameList COMMA DeclarationName

DeclarationName:
    ID

PointerType:
    STAR TypeName

StructType:
    STRUCT OGenericTypeList BLOCK_OPEN StructDeclarationList Ostmtend BLOCK_CLOSE
    STRUCT OGenericTypeList BLOCK_OPEN BLOCK_CLOSE

StructDeclarationList:
    StructDeclaration
    StructDeclarationList STMTEND StructDeclaration

StructDeclaration:
    NewNameList TypeName OLiteral
    Embed OLiteral
    PAREN_OPEN Embed PAREN_CLOSE OLiteral
    STAR Embed OLiteral
    PAREN_OPEN STAR Embed PAREN_CLOSE OLiteral
    STAR PAREN_OPEN Embed PAREN_CLOSE OLiteral

Embed:
    PackName

PackName:
    ID DOT ID
    ID

NewNameList:
    NewName
    NewNameList COMMA NewName

TypeName:
    FunctionType
    PointerType
    OtherType
    DotName
    PAREN_OPEN TypeName PAREN_CLOSE

VarDeclarationList:
    VarDeclarationList STMTEND VarDeclaration
    VarDeclaration

ConstDeclarationList:
    ConstDeclaration
    ConstDeclarationList STMTEND ConstDeclaration

TypeDeclaration:
    TypeDeclarationName TypeName

TypeDeclarationName:
    ID

TypeDeclarationList:
    TypeDeclaration
    TypeDeclarationList STMTEND TypeDeclaration

Expression:
    Expression STAR Expression
    Expression DIV Expression
    Expression MOD Expression
    Expression LS Expression
    Expression RS Expression
    Expression AMPERSAND Expression
    Expression NOT_AND Expression
    Expression ADD Expression
    Expression SUB Expression
    Expression BIT_OR Expression
    Expression CARET Expression
    Expression AND Expression
    Expression OR Expression
    Expression EQ Expression
    Expression NE Expression
    Expression GE Expression
    Expression GT Expression
    Expression LE Expression
    Expression LT Expression
    UnaryExpr

OExpression:
    %
    Expression

UnaryExpr:
    STAR UnaryExpr
    AMPERSAND UnaryExpr
    ADD UnaryExpr
    SUB UnaryExpr
    NOT_OP UnaryExpr
    PrimaryExpr

PrimaryExpr:
    PrimaryExprNoParen
    PAREN_OPEN ExpressionOrType PAREN_CLOSE

ExpressionOrType:
    Expression
    NonExpressionType

DotName:
    Name
    Name DOT ID %prec DotNamePrec

PrimaryExprNoParen:
    Name
    Literal
    PrimaryExpr DOT ID %prec DotNamePrec
    PrimaryExpr DOT PAREN_OPEN ExpressionOrType PAREN_CLOSE
    // ID here is predefined types
    PrimaryExpr DOT PAREN_OPEN TYPE PAREN_CLOSE
    PrimaryExpr SQUARE_OPEN Expression SQUARE_CLOSE
    PrimaryExpr SQUARE_OPEN OExpression COLON OExpression SQUARE_CLOSE
    PrimaryExpr SQUARE_OPEN OExpression COLON OExpression COLON OExpression SQUARE_CLOSE
    ConvType AS PAREN_OPEN Expression OComma PAREN_CLOSE
    CompType BLOCK_OPEN BracedKeyValList BLOCK_CLOSE
    PrimaryExprNoParen SQ_PIPE_OPEN BracedKeyValList SQ_PIPE_CLOSE
    FunctionLiteral
    GeneratorLiteral
    PseudoCall

NonExpressionType:
    FunctionType
    GeneratorType
    OtherType
    STAR NonExpressionType

OtherType:
    SQUARE_OPEN OExpression SQUARE_CLOSE TypeName
    SQUARE_OPEN VARIADIC SQUARE_CLOSE TypeName
    StructType
    InterfaceType

NewName:
    ID

DeclName:
    ID

ONewName:
    %
    NewName

Name:
    ID %prec NotParen

ExpressionList:
    Expression
    ExpressionList COMMA Expression

OExpressionList:
    %
    ExpressionList

OLiteral:
    %
    Literal

Literal:
    RAW_STRING
    INTER_STRING
    DECIMAL_LIT
    OCTAL_LIT
    HEX_LIT
    TRUE
    FALSE

// Function Decl
FunctionDeclaration:
    FUNC OGenericTypeList FunctionHeader FunctionBody

GeneratorDeclaration:
    GEN OGenericTypeList FunctionHeader FunctionBody

FunctionHeader:
    ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult
    PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

ConvType:
    FunctionType
    GeneratorType
    OtherType

CompType:
    OtherType

FunctionType:
    FUNC OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

GeneratorType:
    GEN OGenericTypeList PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

FunctionResult:
    // %prec NotParen
    %
    FunctionReturnType
    PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE

FunctionReturnType:
    FunctionType
    GeneratorType
    OtherType
    DotName

FunctionBody:
    CompoundStatement

OArgumentTypeListOComma:
    %
    ArgumentTypeList OComma

ArgumentTypeList:
    ArgumentType
    ArgumentTypeList COMMA ArgumentType

ArgumentType:
    NameOrType
    ID NameOrType
    ID VARIADIC
    VARIADIC TypeName
    VARIADIC

NameOrType:
    TypeName

OComma:
    COMMA
    %

// Statements
OSimpleStatement:
    %
    SimpleStatement

SimpleStatement:
    Expression
    ExpressionList ASSGN_OP ExpressionList
    ExpressionList DECL ExpressionList
    Expression INC
    Expression DEC

CompoundStatement:
    BLOCK_OPEN StatementList BLOCK_CLOSE

StatementList:
    Statement
    StatementList STMTEND Statement

Statement:
    %
    CompoundStatement
    CommonDeclaration
    NonDeclarationStatement

NonDeclarationStatement:
    SimpleStatement
    IfStatement
    ForStatement
    SwitchStatement
    LabelName COLON Statement
    FALLTHROUGH
    BREAK ONewName
    CONTINUE ONewName
    GOTO NewName
    RETURN OExpressionList
    YIELD OExpressionList

LabelName:
    NewName

IfStatement:
    IF IfHeader LoopBody ElseIfList Else

ElseIf:
    ELSE IF IfHeader LoopBody

ElseIfList:
    %
    ElseIfList ElseIf

Else:
    %
    ELSE CompoundStatement

LoopBody:
    BLOCK_OPEN StatementList BLOCK_CLOSE

IfHeader:
    OSimpleStatement
    OSimpleStatement STMTEND OSimpleStatement

ForStatement:
    FOR ForBody

ForBody:
    ForHeader LoopBody

ForHeader:
    OSimpleStatement STMTEND OSimpleStatement STMTEND OSimpleStatement
    OSimpleStatement
    RangeStatement

RangeStatement:
    ExpressionList ASSGN_OP RANGE Expression
    ExpressionList DECL RANGE Expression
    RANGE Expression

SwitchStatement:
    SWITCH IfHeader BLOCK_OPEN CaseBlockList BLOCK_CLOSE

CaseBlockList:
    %
    CaseBlockList CaseBlock

CaseBlock:
    Case StatementList

Case:
    CASE ExpressionOrTypeList COLON
    CASE ExpressionOrTypeList ASSGN_OP Expression COLON
    CASE ExpressionOrTypeList DECL Expression COLON
    DEFAULT COLON

ExpressionOrTypeList:
    ExpressionOrTypeList COMMA ExpressionOrType
    ExpressionOrType

// Main main
InterfaceDeclaration:
    NewName InterfaceDecl
    PAREN_OPEN PackName PAREN_CLOSE
    PackName

// Helper
InterfaceDecl:
    PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

InterfaceDeclarationList:
    InterfaceDeclaration
    InterfaceDeclarationList STMTEND InterfaceDeclaration

InterfaceType:
    INTERFACE BLOCK_OPEN InterfaceDeclarationList Ostmtend BLOCK_CLOSE
    INTERFACE BLOCK_OPEN BLOCK_CLOSE

// Literals
FunctionLiteral:
    FunctionLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE
    // FunctionLiteralDeclaration Error

GeneratorLiteral:
    GeneratorLiteralDeclaration BLOCK_OPEN StatementList BLOCK_CLOSE

FunctionLiteralDeclaration:
    FunctionType

GeneratorLiteralDeclaration:
    GeneratorType

KeyVal:
    Expression COLON CompLiteralExpression

KeyValList:
    KeyVal
    BareCompLiteralExpression
    KeyValList COMMA KeyVal
    KeyValList COMMA BareCompLiteralExpression

BareCompLiteralExpression:
    Expression
    BLOCK_OPEN BracedKeyValList BLOCK_CLOSE

CompLiteralExpression:
    Expression
    BLOCK_OPEN BracedKeyValList BLOCK_CLOSE

BracedKeyValList:
    %
    KeyValList OComma

TypeNameList:
    TypeName
    TypeNameList COMMA TypeName

GenericType:
    Name
    Name COLON TypeNameList

GenericTypeList:
    GenericType
    GenericTypeList GENERIC_CONCAT GenericType

OGenericTypeList:
    LT GenericTypeList GT
    %

PseudoCall:
    PrimaryExpr PAREN_OPEN PAREN_CLOSE
    PrimaryExpr PAREN_OPEN ExpressionOrTypeList OComma PAREN_CLOSE
    PrimaryExpr PAREN_OPEN ExpressionOrTypeList VARIADIC OComma PAREN_CLOSE

