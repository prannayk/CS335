#include "symboltable.h"

// SymbolTableEntry

SymbolTableEntry::SymbolTableEntry(string aName, Type aType)
{
    name = aName;
    dirty = valid = false;
    reg = NONE;
    type = aType;
}

// SymbolTable

SymbolTable::SymbolTable()
{
    globalScope = NULL;
    parentScope = NULL;
}

void
SymbolTable::addEntry(SymbolTableEntry* a)
{
    table[a->getName()] = a;
}

SymbolTableEntry*
SymbolTable::getEntry(string a)
{
    if (table.count(a)) { // slick way of checking for existance of key
        return table[a];
    }
    return NULL;
}

bool SymbolTable::checkEntry(string a){ if(getEntry(a) == NULL) return true; return false; }

void
SymbolTable::resetNextUseInfo(int a) {
  map<string, SymbolTableEntry*>::iterator iter;
  for (iter = table.begin(); iter != table.end(); iter++) {
    (*(iter->second)).setLive(false);
    (*(iter->second)).setNextUse(a);
  }
}
