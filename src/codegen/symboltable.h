#include <string>
#include <map>

using namespace std;

class SymbolTableEntry {

  private:

    string name;

    bool dirty;
    bool valid;

    int reg;

  public:

    // Getters
    string nameGet()           { return name; }

    bool dirtyGet()            { return dirty; }
    bool validGet()            { return valid; }

    int regGet()               { return reg; }

    // Setters
    void nameSet(string a)     { name = a; }

    void dirtySet(bool a)      { dirty = a; }
    void validSet(bool a)      { valid = a; }

    void regSet(int a)         { reg = a; }

};

class SymbolTable {

  private:

     map<string, SymbolTableEntry*> table;

     SymbolTable* parentscope;
     SymbolTable* globalscope;

  public:

    void addEntry(SymbolTableEntry* a);
    void getEntry(string a);

    // Getters
    SymbolTable* parentscopeGet()          { return parentscope; }
    SymbolTable* globalscopeGet()          { return globalscope; }

    // Setters
    void parentscopeSet(SymbolTable* a)    { parentscope = a; }
    void globalscopeSet(SymbolTable* a)    { globalscope = a; }



};
