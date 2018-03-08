def source_to_rules(filename):
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
        else:
            pipes.append(line.strip())
    return rules


rules = source_to_rules("grammar.g")

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

