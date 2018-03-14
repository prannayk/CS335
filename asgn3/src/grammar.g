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

CommonDeclaration:
    VAR VarDeclaration
    VAR PAREN_OPEN VarDeclarationList Ostmtend PAREN_CLOSE
    VAR PAREN_OPEN PAREN_CLOSE
    CONST ConstDeclaration
    CONST PAREN_OPEN ConstDeclarationList Ostmtend PAREN_CLOSE
    CONST PAREN_OPEN PAREN_CLOSE

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

TypeName:
    ID

VarDeclarationList:
    VarDeclarationList STMTEND VarDeclaration
    VarDeclaration

ConstDeclarationList:
    ConstDeclaration
    ConstDeclarationList STMTEND ConstDeclaration

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
    ID %prec NotParen

ExpressionList:
    Expression
    ExpressionList COMMA Expression

OExpressionList:
    %
    ExpressionList

Literal:
    RAW_STRING
    INTER_STRING
    DECIMAL_LIT
    OCTAL_LIT
    HEX_LIT

