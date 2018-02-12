#pragma once

#include "enums.h"
#include <map>
#include <string>

using namespace std;

class SymbolTableEntry
{
  private:
    string name;

    bool dirty;
    bool valid;

    Register reg;

    Type type;

    bool live;
    int nextUse;
    int active; // for use in register descriptor table
  public:
    // Constructor
    SymbolTableEntry(string aName, Type aType);

    // Getters
    string getName() const { return name; }

    bool getDirty() const { return dirty; }
    bool getValid() const { return valid; }

    Register getReg() const { return reg; }

    Type getType() const { return type; }

    bool getLive() const { return live; }
    int getNextUse() const { return nextUse; }
    int getUse() const { return active; }
    // Setters
    void setName(string a) { name = a; }

    void setDirty(bool a) { dirty = a; }
    void setValid(bool a) { valid = a; }

    void setReg(Register a) { reg = a; }

    void setType(Type a) { type = a; }

    void setLive(bool a) { live = a; }
    void setNextUse(int a) {nextUse = a; }

    void setUse(int a) { active = a; } 
};

class SymbolTable
{
  private:
    SymbolTable* parentScope;
    SymbolTable* globalScope;

  public:
    map<string, SymbolTableEntry*> table;
    void addEntry(SymbolTableEntry* a);
    SymbolTableEntry* getEntry(string a);
    bool checkEntry(string a);
    void resetNextUseInfo(int a);

    // Constructor
    SymbolTable();

    // Getters
    SymbolTable* getParentScope() const { return parentScope; }
    SymbolTable* getGlobalScope() const { return globalScope; }

    // Setters
    void setParentScope(SymbolTable* a) { parentScope = a; }
    void setGlobalScope(SymbolTable* a) { globalScope = a; }
};
