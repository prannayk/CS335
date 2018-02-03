#pragma once

#include "enums.h"
#include "symboltable.h"

#include <map>
#include <string.h>
#include <vector>

using namespace std;

class ComplexBlock;
class SimpleBlock;
class Instruction;

class Instruction
{
  private:
    OpCode op;

    void* v1;
    void* v2;
    void* v3;

    AddressingMode v1AddMode;
    AddressingMode v2AddMode;
    AddressingMode v3AddMode;

    Type v1Type;
    Type v2Type;
    Type v3Type;

  public:
    // Getters
    OpCode getOp() { return op; }

    void* getV1() { return v1; }
    void* getV2() { return v2; }
    void* getV3() { return v3; }

    AddressingMode getV1AddMode() { return v1AddMode; }
    AddressingMode getV2AddMode() { return v2AddMode; }
    AddressingMode getV3AddMode() { return v3AddMode; }

    Type getV1Type() { return v1Type; }
    Type getV2Type() { return v2Type; }
    Type getV3Type() { return v3Type; }

    // Setters
    void setOp(OpCode a) { op = a; }

    void setV1(void* a) { v1 = a; }
    void setV2(void* a) { v2 = a; }
    void setV3(void* a) { v3 = a; }

    void setV1AddMode(AddressingMode a) { v1AddMode = a; }
    void setV2AddMode(AddressingMode a) { v2AddMode = a; }
    void setV3AddMode(AddressingMode a) { v3AddMode = a; }

    void setV1Type(Type a) { v1Type = a; }
    void setV2Type(Type a) { v2Type = a; }
    void setV3Type(Type a) { v3Type = a; }
};

class SimpleBlock
{
  private:
    vector<Instruction*> instructions;
    int label;
    ComplexBlock* reverse;
    SymbolTable* symboltable;

  public:
    Instruction* firstInstruction() const;
    int length() const;
    void addInstruction(Instruction* a);

    // Getters
    int getLabel() const { return label; }
    ComplexBlock* getReverse() const { return reverse; }
    SymbolTable* getSymboltable() const { return symboltable; }

    // Setters
    void setLabel(int a) { label = a; }
    void setReverse(ComplexBlock* a) { reverse = a; }
    void setSymboltable(SymbolTable* a) { symboltable = a; }

    // Constructor
    // SimpleBlock(...);
};

class ComplexBlock
{
  private:
    map<int, SimpleBlock*> blocks;
    int firstblock;
    string label;
    int numlabel;

  public:
    void addBlock(SimpleBlock* a);
    int length() const;
    SimpleBlock* firstBasicBlock() const;

    // Getters
    int getFirstblock() { return firstblock; }
    string getLabel() { return label; }
    int getNumlabel() { return numlabel; }

    // Setters
    void setFirstblock(int a) { firstblock = a; }
    void setLabel(string a) { label = a; }
    void setNumlabel(int a) { numlabel = a; }

    // Constructor
    // ComplexBlock(...);
};
