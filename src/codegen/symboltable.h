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

    int reg;

    Type type;

  public:
    // Constructor
    SymbolTableEntry(string aName, Type aType);

    // Getters
    string getName() const { return name; }

    bool getDirty() const { return dirty; }
    bool getValid() const { return valid; }

    int getReg() const { return reg; }

    Type getType() const { return type; }

    // Setters
    void setName(string a) { name = a; }

    void setDirty(bool a) { dirty = a; }
    void setValid(bool a) { valid = a; }

    void setReg(int a) { reg = a; }

    void setType(Type a) { type = a; }
};

class SymbolTable
{
  private:
    map<string, SymbolTableEntry*> table;

    SymbolTable* parentScope;
    SymbolTable* globalScope;

  public:
    void addEntry(SymbolTableEntry* a);
    SymbolTableEntry* getEntry(string a);

    // Constructor
    SymbolTable(SymbolTable* aParentScope, SymbolTable* aGlobalScope);

    // Getters
    SymbolTable* getParentScope() const { return parentScope; }
    SymbolTable* getGlobalScope() const { return globalScope; }

    // Setters
    void setParentScope(SymbolTable* a) { parentScope = a; }
    void setGlobalScope(SymbolTable* a) { globalScope = a; }
};
