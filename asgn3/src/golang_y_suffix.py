print('''
%%

int main(int argc, char** argv) {
	FILE *myfile = fopen(argv[1], "r");
        yyin = myfile;
        do {
            yyparse();
        } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s) {
    printf("ParseError: %s\\n", s);
    exit(-1);
}
''')
