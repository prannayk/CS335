#pragma once

#include "enums.h"
#include "symboltable.h"
#include <map>
#include <string>

using namespace std;

class RegisterDescriptor
{
  private:
    map<Register, SymbolTableEntry*> regDescTable;

  public:
    void setRegisterSTE(Register aReg, SymbolTableEntry* aSte);
    SymbolTableEntry* getRegisterSTE(Register aReg);
    string getX86Name(Register aReg);
    map<Register, SymbolTableEntry*>* getRegTable(){ return &regDescTable; }
    RegisterDescriptor();
};
