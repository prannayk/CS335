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
    ID

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
    STRUCT BLOCK_OPEN StructDeclarationList Ostmtend BLOCK_CLOSE
    STRUCT BLOCK_OPEN BLOCK_CLOSE

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

PrimaryExprNoParen:
    Name
    Literal
    PrimaryExpr DOT ID
    PrimaryExpr DOT PAREN_OPEN ExpressionOrType PAREN_CLOSE
    PrimaryExpr DOT PAREN_OPEN TypeName PAREN_OPEN
    PrimaryExpr SQUARE_OPEN Expression SQUARE_CLOSE
    PrimaryExpr SQUARE_OPEN OExpression COLON OExpression SQUARE_CLOSE
    PrimaryExpr SQUARE_OPEN OExpression COLON OExpression COLON OExpression SQUARE_CLOSE

NonExpressionType:
    // FunctionType
    OtherType
    STAR NonExpressionType

OtherType:
    SQUARE_OPEN SQUARE_CLOSE

// FunctionType:
    // FUNC PAREN_OPEN
    //
NewName:
    ID

DeclName:
    ID

ONewName:
    %
    NewName

Name:
    ID

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

// Function Decl
FunctionDeclaration:
    FUNC FunctionHeader FunctionBody

FunctionHeader:
    ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult
    PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE ID PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

ConvType:
    FunctionType
    OtherType

CompType:
    OtherType

FunctionType:
    FUNC PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE FunctionResult

FunctionResult:
    %
    FunctionReturnType
    PAREN_OPEN OArgumentTypeListOComma PAREN_CLOSE

FunctionReturnType:
    FunctionType
    OtherType
    DotName

DotName:
    Name
    Name DOT ID

FunctionBody:
    BLOCK_OPEN ADD STMTEND BLOCK_CLOSE

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

