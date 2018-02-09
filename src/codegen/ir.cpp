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

void
IR::fillStructure() {

  vector<int> leaders;
  vector<int> complexBegin;
  vector<int> complexEnd;

  using Iter = vector<int>::const_iterator;
  int num = 0;
  for (Iter it = i_list.begin(); it!= i_list.end(); it++) {
    
    num = num + 1;
  }

}
