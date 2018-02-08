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

SymbolTable::SymbolTable(SymbolTable* aParentScope, SymbolTable* aGlobalScope)
{
    globalScope = aGlobalScope;
    parentScope = aParentScope;
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
