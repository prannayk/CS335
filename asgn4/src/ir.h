#pragma once

#include "Node.h"
#include "registerdescriptor.h"
#include "block.h"
#include "enums.h"
#include <iostream>
#include <map>
#include <string.h>
#include <vector>

#define MAXVECTORSIZE 1000

using namespace std;

class IR
{
  private:
    ST* rootST;
    vector<Instruction*> i_list;
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
                         STEntry* current); // get Reg function

    // Constructor
    IR(vector<Instruction*>, ST*);

    // Getters
    ST* getRootST() { return rootST; }
    string getGlobalComplexName() { return globalComplexName; }
    vector<SimpleBlock*> getSimpleBlockList() { return simpleBlockList; }

    // Setters
    void setRootST(ST* a) { rootST = a; }
    // Print instruction opCode
    void printInstruction();
};
