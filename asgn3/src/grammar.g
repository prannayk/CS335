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

Expression:
    Term ADD Expression
    Term SUB Expression
    Term

Term:
    Factor STAR Term
    Factor DIV Term
    Factor

Factor:
    PAREN_OPEN Expression PAREN_CLOSE
    FLOAT_LIT
    ID

