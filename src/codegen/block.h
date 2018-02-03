#include "enums.h"
#include "symboltable.h"

#include <string.h>
#include <vector>
#include <map>

using namespace std;

class Instruction {
private:
  OpCode op;

  void* v1;
  void* v2;
  void* v3;

  Variability v1var;
  Variability v2var;
  Variability v3var;

  Type v1type;
  Type v2type;
  Type v3type;

public:

  // Getters
  OpCode opGet()                { return op; }

  void* v1Get()                  { return v1; }
  void* v2Get()                  { return v2; }
  void* v3Get()                  { return v3; }

  Variability v1varGet()               { return v1var; }
  Variability v2varGet()               { return v2var; }
  Variability v3varGet()               { return v3var; }

  Type v1typeGet()              { return v1type; }
  Type v2typeGet()              { return v2type; }
  Type v3typeGet()              { return v3type; }

  // Setters
  void opSet(OpCode a)          { op = a; }

  void v1Set(void* a)            { v1 = a; }
  void v2Set(void* a)            { v2 = a; }
  void v3Set(void* a)            { v3 = a; }

  void v1varSet(Variability a)  { v1var = a; }
  void v2varSet(Variability a)  { v2var = a; }
  void v3varSet(Variability a)  { v3var = a; }

  void v1typeSet(Type a)        { v1type = a; }
  void v2typeSet(Type a)        { v2type = a; }
  void v3typeSet(Type a)        { v3type = a; }

};

class SimpleBlock {

  private:

    vector<Instruction*> instructions;
    int label;
    class ComplexBlock* reverse;  // the class keyword is since its not yet declared
    SymbolTable* symboltable;

  public:

    Intruction* firstInstruction();
    int length();
    void addInstruction(Instruction* a);

    //Getters
    int labelGet()                       { return label; }
    ComplexBlock* reverseGet()           { return reverse; }
    SymbolTable* symboltableGet()        { return symboltable; }

    //Setters
    void labelGet(int a)                 { label = a;}
    void reverseGet(ComplexBlock* a)     { reverse = a;}
    void symboltableGet(SymbolTable* a)  { symboltable = a;}

};

class ComplexBlock {

  private:

    map<int, SimpleBlock*> blocks;
    int firstblock;
    string label;
    int numlabel;

  public:

    void addBlock(SimpleBlock* a);
    int length();
    SimpleBlock* firstBasicBlock();

    //Getters
    int firstblockGet()          { return firstblock; }   
    string labelGet()            { return label; }
    int numlabelGet()            { return numlabel; }

    //Setters
    void firstblockSet(int a)    { firstblock = a; }
    void labelSet(string a)      { label = a; }
    void numlabelSet(int a)      { numlabel = a; }

};
