StartSymbol:
    RMBlockStmt

RMBlockStmt:
    SimpleStmt RMBlockStmt
    %

SimpleStmt:
    EmptyStmt
    ExpressionStmt
    Assignment

EmptyStmt:
    STMTEND 

ExpressionStmt:
    Expression STMTEND

Assignment:
    Expression ExpressionBuild Expression STMTEND

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
    BLOCK_OPEN ElementLists BLOCK_CLOSE
    BLOCK_OPEN ElementList COMMA BLOCK_CLOSE

ElementList:
    KeyedElement KeyedElements

KeyedElements:
    COMMA KeyedElement KeyedElements
    %

KeyedElement:
    Element
    Key  Element

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
    Expression BIN_OP Expression
    UnaryExpr

