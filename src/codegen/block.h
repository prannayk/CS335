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

    int v1num, v2num, v3num;

    int numOps;

  public:
    // Constructors
    Instruction(OpCode aOp, void* aV1, void* aV2, void* aV3,
                AddressingMode aV1AddMode, AddressingMode aV2AddMode,
                AddressingMode aV3AddMode, Type aV1Type, Type aV2Type,
                Type aV3Type);
    Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         void* aV3,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         AddressingMode aV3AddMode,
                         Type aV1Type,
                         Type aV2Type,
                         Type aV3Type, 
                         int aV1num, 
                         int aV2num, 
                         int aV3num);

    Instruction(OpCode aOp, void* aV1, void* aV2, AddressingMode aV1AddMode,
                AddressingMode aV2AddMode, Type aV1Type, Type aV2Type);
    Instruction(OpCode aOp, void* aV1, void* aV2, AddressingMode aV1AddMode,
                AddressingMode aV2AddMode, Type aV1Type, Type aV2Type, int aV2Num); // for function declaration only

    Instruction(OpCode aOp,
                void* aV1,
                void* aV2,
                AddressingMode aV1AddMode,
                AddressingMode aV2AddMode,
                Type aV1Type,
                Type aV2Type, 
                int aV1num, int aV2num);
    Instruction(OpCode aOp, void* aV1, AddressingMode aV1AddMode, Type aV1Type);
    Instruction(OpCode aOp);
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

    int getNumOps() { return numOps; }

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

    // Print Instruction 
    void printInstruction();
};

class SimpleBlock
{
  private:
    vector<Instruction*> instructions;
    int label;
    ComplexBlock* reverse;
    SimpleBlock* nextBlock;

  public:
    // Constructor
    SimpleBlock(int aLabel, ComplexBlock* aReverse);

    void addInstruction(Instruction* a);
    Instruction* firstInstruction() const;
    int length() const;

    // Getters
    int getLabel() const { return label; }
    ComplexBlock* getReverse() const { return reverse; }
    SimpleBlock* getNextBlock() const { return nextBlock; }

    // Setters
    void setLabel(int a) { label = a; }
    void setReverse(ComplexBlock* a) { reverse = a; }
    void setNextBlock(SimpleBlock* a) { nextBlock = a; }
};

class ComplexBlock
{
  private:
    map<int, SimpleBlock*> blocks;
    int firstBlock;
    string label;
    int numLabel;

  public:
    void addBlock(SimpleBlock* a);
    int length() const;
    SimpleBlock* firstBasicBlock();

    // Constructor
    ComplexBlock(string aLabel, int aNumLabel);

    // Getters
    int getFirstBlock() { return firstBlock; }
    string getLabel() { return label; }
    int getNumLabel() { return numLabel; }

    // Setters
    void setFirstBlock(int a) { firstBlock = a; }
    void setLabel(string a) { label = a; }
    void setNumLabel(int a) { numLabel = a; }
};
