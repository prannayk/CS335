#include "block.h"
#include "enums.h"
#include "registerdescriptor.h"
#include "symboltable.h"
#include <iostream>
#include <map>
#include <string.h>
#include <vector>

using namespace std;

class IR
{
  private:
    SymbolTable* rootSymbolTable;
    vector<Instruction> i_list;
    string globalComplexName;
    map<string, int> basicBlockMap;
    vector<SimpleBlock*> simpleBlockList;
    RegisterDescriptor RegDescTable;

  public:
    map<string, ComplexBlock*> complexBlocks;
    void addGlobalComplex(ComplexBlock* a);
    void addComplexBlock(ComplexBlock* a);
    ComplexBlock* getComplexBlock(string a);
    int utilGetNumComplexBlock();

    void fillStructure();
    Register getRegister(int flag,
                         SymbolTableEntry* current); // get Reg function

    // Constructor
    IR(vector<Instruction>, SymbolTable*);

    // Getters
    SymbolTable* getRootSymbolTable() { return rootSymbolTable; }
    string getGlobalComplexName() { return globalComplexName; }
    vector<SimpleBlock*> getSimpleBlockList() { return simpleBlockList; }

    // Setters
    void setRootSymbolTable(SymbolTable* a) { rootSymbolTable = a; }
    // Print instruction opCode
    void printInstruction();
};
