#include "ir.h"

// IR

IR::IR(char **lines, int size)
{
    for(int i=0; i<size; i++) { // iterate through the lines and extract instructions / code and create complex blocks
        // put in lexer stuff        
    }
}

void
IR::addGlobalComplex(ComplexBlock* a)
{
    // The global complex block has a single
    // simple block, whose symbol table has global variables

    globalComplexName = a->getLabel();
    complexBlocks[globalComplexName] = a;
    rootSymbolTable = (a->firstBasicBlock())->getSymbolTable();
}

void
IR::addComplexBlock(ComplexBlock* a)
{
    complexBlocks[a->getLabel()] = a;
}

ComplexBlock*
IR::getComplexBlock(string a)
{
    return complexBlocks[a];
}
