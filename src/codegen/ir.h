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

    string globalComplexName;

  public:
    // Constructor
    // IR(...);

    // Getters
    SymbolTable* getRootSymbolTable() { return rootSymbolTable; }
    string getGlobalComplexName() { return globalComplexName; }

    // Setters
    void setRootSymbolTable(SymbolTable* a) { rootSymbolTable = a; }
};
