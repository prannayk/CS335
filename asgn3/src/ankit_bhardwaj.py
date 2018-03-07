rules = [
       [ "SourceFile" , [ "PackageClause STMTEND ImportDecls TopLevelDecls" ]],
       [ "PackageClause" , ["PACKAGE ID"]],
       [ "ImportDecls" , [ "ImportDecl ImportDecls","ImportDecl"]],
       [ "ImportDecl" , [ "IMPORT ID STMTEND"]],
       [ "TopLevelDecls" , [ "TopLevelDecl TopLevelDecls","TopLevelDecl"]],
       [ "TopLevelDecl" , [ "expression STMTEND"]],
 
       [ "expression" , [ "term ADD expression", 
                         "term SUB expression",
                         "term" ]],
       [ "term" , [ "factor STAR term",
                   "factor DIV term",
                   "factor" ]],
       [ "factor" , [ "PAREN_OPEN expression PAREN_CLOSE",
                     "FLOAT_LIT" ]
        ]
]

import golang_y_prefix

for key, value in rules:
    print(key, " :")
    p_stmt = []
    for pipe in value:
        index = 0
        vat_new = []
        for vat in pipe.split():
            index += 1
            if vat.upper() == vat:
                # Terminal
                vat_new.append('"{}" << " " << ${}'.format(vat.lower(), index))
            else:
                # Non Terminal
                vat_new.append('"' + vat + '"')

        if pipe != "":
            p_stmt.append(pipe + " { cout <<" + '<< " " <<'.join(vat_new) + " << endl ;}\n")
        else:
            p_stmt.append(pipe)
    print("\t\t| ".join(p_stmt))
    print(";")


import golang_y_suffix
