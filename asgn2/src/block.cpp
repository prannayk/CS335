#include "block.h"
#include <stdio.h>
// Instructions

void addToSymbolTable();

Instruction::Instruction(OpCode aOp,
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
                         int aV3num)
{
    op = aOp;
    numOps = 3;
    v1 = aV1;
    v2 = aV2;
    v3 = aV3;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v3AddMode = aV3AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v3Type = aV3Type;
    v1num = aV1num;
    v2num = aV2num;
    v3num = aV3num;
}

Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         void* aV3,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         AddressingMode aV3AddMode,
                         Type aV1Type,
                         Type aV2Type,
                         Type aV3Type)
{
    op = aOp;
    numOps = 3;
    v1 = aV1;
    v2 = aV2;
    v3 = aV3;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v3AddMode = aV3AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v3Type = aV3Type;
}

Instruction::Instruction(OpCode aOp, void* aV1, void* aV2,
                         AddressingMode aV1AddMode, AddressingMode aV2AddMode,
                         Type aV1Type, Type aV2Type)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
}
Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         Type aV1Type,
                         Type aV2Type,
                         int aV1num, int aV2num)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v1num = aV1num;
    v2num = aV2num;
}
Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         Type aV1Type,
                         Type aV2Type, 
                         int aV2num)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v2num = aV2num;
}

Instruction::Instruction(OpCode aOp, void* aV1, AddressingMode aV1AddMode,
                         Type aV1Type)
{
    op = aOp;
    numOps = 1;
    v1 = aV1;
    v1AddMode = aV1AddMode;
    v1Type = aV1Type;
}

Instruction::Instruction(OpCode aOp, void* aV1, AddressingMode aV1AddMode,
                         Type aV1Type, int numV1)
{
    op = aOp;
    numOps = 1;
    v1 = aV1;
    v1AddMode = aV1AddMode;
    v1Type = aV1Type;
    v1num = numV1;
}

Instruction::Instruction(OpCode aOp)
{
    numOps = 0;
    op = aOp;
    v1AddMode = NONE_MODE;
    v1Type = NONE_TYPE;
}

void Instruction::printInstruction(){
    printf("%d %d %d\n", op, v1AddMode, v1Type);
}


// Simple Blocks

SimpleBlock::SimpleBlock(int aLabel, ComplexBlock* aReverse)
{
    label = aLabel;
    reverse = aReverse;
}

void
SimpleBlock::addInstruction(Instruction* a)
{
    instructions.push_back(a);
}

Instruction*
SimpleBlock::firstInstruction() const
{
    return instructions.front();
}

int
SimpleBlock::length() const
{
    return instructions.size();
}

// Complex Block

ComplexBlock::ComplexBlock(string aLabel, int aNumLabel)
{
    label = aLabel;
    numLabel = aNumLabel;
}

void
ComplexBlock::addBlock(SimpleBlock* a)
{
    blocks[a->getLabel()] = a;
    if (blocks.size() == 1) { // if first, then store it
        firstBlock = a->getLabel();
    }
}

int
ComplexBlock::length() const
{
    return blocks.size();
}

SimpleBlock*
ComplexBlock::firstBasicBlock()
{
    if (blocks.size() > 0) {
        return blocks[firstBlock];
    }
    return NULL;
}

void
ComplexBlock::utilPrintSummary() {
  cout << endl << "Summary" << endl;
  map<int, SimpleBlock*>::iterator it;
  for (it = blocks.begin(); it != blocks.end(); it++) {
    cout << "Key, Value: " << it->first << it->second <<endl;
    cout << "Length: " << it->second->length() << endl;
  }
}
