#pragma once

#include "enums.h"
#include "Node.h"
#include <map>
#include <string>

using namespace std;

class RegisterDescriptor
{
  private:
    map<Register, STEntry*> regDescTable;

  public:
    void setRegisterSTE(Register aReg, STEntry* aSte);
    STEntry* getRegisterSTE(Register aReg);
    static string getX86Name(Register aReg);
    map<Register, STEntry*>* getRegTable(){ return &regDescTable; }
    RegisterDescriptor();
};
