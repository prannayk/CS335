#include "block.h"

// Instructions

Instruction::Instruction(OpCode op, void* aV1, void* aV2, void* aV3,
                         AddressingMode aV1AddMode, AddressingMode aV2AddMode,
                         AddressingMode aV3AddMode, Type aV1Type, Type aV2Type,
                         Type aV3Type)
{

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

Instruction::Instruction(OpCode op, void* aV1, void* aV2,
                         AddressingMode aV1AddMode, AddressingMode aV2AddMode,
                         Type aV1Type, Type aV2Type)
{

    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
}

Instruction::Instruction(OpCode op, void* aV1, AddressingMode aV1AddMode,
                         Type aV1Type)
{

    numOps = 1;
    v1 = aV1;
    v1AddMode = aV1AddMode;
    v1Type = aV1Type;
}

// Simple Blocks

SimpleBlock::SimpleBlock(int aLabel, ComplexBlock* aReverse,
                         SymbolTable* aSymbolTable)
{
    label = aLabel;
    reverse = aReverse;
    symbolTable = aSymbolTable;
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
