def source_to_rules(filename):
    list_of_non_terminals = []
    f = open(filename, "r")
    rules = []
    rule = []
    pipes = []
    for line in f:
        if line.strip() == "":
            rule.append(pipes)
            rules.append(rule)
            rule = []
            pipes = []
        elif (line.strip())[-1] == ":":
            rule.append(line[:-2])
            list_of_non_terminals.append(line[:-2])
        elif (line.strip())[-1] == "%":
            pipes.append("")
        else:
            pipes.append(line.strip())
    return (rules, list_of_non_terminals)


rules, list_of_non_terminals = source_to_rules("grammar.g")

import golang_y_prefix

print('\n'.join(['%type\t\t<nt>\t\t' + x for x in list_of_non_terminals]))
print("%%")

for key, value in rules:
    print(key, " :")
    p_stmt = []
    for pipe in value:
        index = 0
        stmt_list = ['$$ = new Node("{}", NOTYPE);'.format(key)]
        vat_new = []
        for vat in pipe.split():
            index += 1
            stmt_list.append('$$->Add(${});'.format(index))
            if vat.upper() == vat:
                # Terminal
                vat_new.append('"{}" << " " << ${}'.format(vat.lower(), index))
            else:
                # Non Terminal
                vat_new.append('"' + vat + '"')

        if pipe != "":
            stmt = pipe
            stmt += "{"
            stmt += '\n'.join(stmt_list)
            if key == "StartSymbol":
                stmt += '$$->PrintJS();'
            stmt += "cout <<" + '<< " " <<'.join(vat_new) + " << endl ;}\n"
            p_stmt.append(stmt)
            # p_stmt.append(pipe + " { " + '\n'.join(stmt_list) + "cout <<" + '<< " " <<'.join(vat_new) + " << endl ; }\n")
        else:
            stmt_list.append('$$->Add({});'.format('""'))
            p_stmt.append("/* Empty Rule */ {" + '\n'.join(stmt_list) + "}")
    print("\t\t| ".join(p_stmt))
    print(";")


import golang_y_suffix

