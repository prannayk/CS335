#include "ir.h"

// IR

IR::IR(vector<Instruction> instr_list)
{
    i_list = instr_list;
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
