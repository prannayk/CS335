#include "block.h"
#include "enums.h"
#include "symboltable.h"

#include <map>
#include <string.h>
#include <vector>

class IR
{
  private:
    SymbolTable* rootSymbolTable;
    map<string, ComplexBlock*> complexBlocks;
    vector<Instruction> i_list;
    string globalComplexName;

  public:
    void addGlobalComplex(ComplexBlock* a);
    void addComplexBlock(ComplexBlock* a);
    ComplexBlock* getComplexBlock(string a);

    // Constructor
    IR(vector<Instruction>);

    // Getters
    SymbolTable* getRootSymbolTable() { return rootSymbolTable; }
    string getGlobalComplexName() { return globalComplexName; }

    // Setters
    void setRootSymbolTable(SymbolTable* a) { rootSymbolTable = a; }
};
