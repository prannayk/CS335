StartSymbol:
    Block

Block:
    BLOCK_OPEN StatementList BLOCK_CLOSE
    VarDecl

StatementList:
    Statement STMTEND StatementList
    %

Statement:
    SimpleStmt

SimpleStmt:
    EmptyStmt
    ExpressionStmt
    Assignment

EmptyStmt:
    %

ExpressionStmt:
    Expression

Assignment:
    Expression ExpressionBuild Expression 

ExpressionBuild:
    ASSGN_OP
    COMMA Expression ExpressionBuild Expression COMMA

Operand:
    Literal
    OperandName

OperandName:
    ID

Literal:
    BasicLit

BasicLit:
    DECIMAL_LIT
    FLOAT_LIT
    STRING_LIT

LiteralValue:
    BLOCK_OPEN BLOCK_CLOSE
    BLOCK_OPEN ElementList BLOCK_CLOSE
    BLOCK_OPEN ElementList COMMA BLOCK_CLOSE

ElementList:
    KeyedElement KeyedElements

KeyedElements:
    COMMA KeyedElement KeyedElements
    %

KeyedElement:
    Element
    Key Element

Element:
    Expression
    LiteralValue

Key:
    FieldName
    Expression
    LiteralValue

FieldName:
    ID

PrimaryExpr:
    Operand

UnaryExpr:
    UNARY_OP UnaryExpr
    PrimaryExpr

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
    UnaryExpr

Type:
    TypeName

TypeName:
    ID

ExpressionList:
    Expression ExpressionListHelp

ExpressionListHelp:
    %
    COMMA Expression ExpressionListHelp

IdentifierList:
    ID IdentifierListHelp

IdentifierListHelp:
    %
    COMMA ID IdentifierListHelp

VarSpec:
    IdentifierList Type
    IdentifierList Type ASSGN_OP ExpressionList
    IdentifierList ASSGN_OP ExpressionList

VarDecl:
    VAR VarSpec
    VAR PAREN_OPEN VarDeclHelp PAREN_CLOSE

VarDeclHelp:
    VarSpec STMTEND VarDeclHelp
    %

