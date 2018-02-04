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

    // Constructor
    // Note: please move this to .cpp file, this is for demo.
    /*
    SymbolTableEntry(string aName)
      : name(aName)
      , valid(false)
      , dirty(false)
      , reg(0)
      , type(Type::INT)
    {
    } */
};

class SymbolTable
{
  private:
    map<string, SymbolTableEntry*> table;

    SymbolTable* parentscope;
    SymbolTable* globalscope;

  public:
    void addEntry(SymbolTableEntry* a);
    void getEntry(string a) const;

    // Getters
    SymbolTable* getParentscope() const { return parentscope; }
    SymbolTable* getGlobalscope() const { return globalscope; }

    // Setters
    void setParentscope(SymbolTable* a) { parentscope = a; }
    void setGlobalscope(SymbolTable* a) { globalscope = a; }

    // Constructor
    // Note: please move this to .cpp file, this is for demo.
    /*
    SymbolTable(SymbolTable* aParentscope, SymbolTable* aGlobalscope)
      : globalscope(aGlobalscope)
      , parentscope(aParentscope)
      , table()
    {
    } */
};
