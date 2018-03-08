SourceFile:
    PackageClause STMTEND ImportDecls TopLevelDecls

PackageClause:
    PACKAGE ID

ImportDecls:
    ImportDecl ImportDecls
    ImportDecl

ImportDecl:
    IMPORT ID STMTEND
    %

TopLevelDecls:
    TopLevelDecl TopLevelDecls
    TopLevelDecl

TopLevelDecl:
    expression STMTEND
    %

expression:
    term ADD expression
    term SUB expression
    term

term:
    factor STAR term
    factor DIV term
    factor

factor:
    PAREN_OPEN expression PAREN_CLOSE
    FLOAT_LIT

