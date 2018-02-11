#pragma once

#include <fstream>
#include <iostream>
#include <string>
#include <cassert>

#include "block.h"
#include "enums.h"
#include "registerdescriptor.h"

#define LABELPREFIX "label"
#define OUTPUTNAME output
#define REGDESC regDesc
#define COMPARELABEL "cmpLabel"
#define INST(I) OUTPUTNAME << #I << "\t"
#define LINST(I) INST(I) << endl
#define ARG(op) OUTPUTNAME << REGDESC.getX86Name(op->getReg()) << ", "
#define LARG(op) OUTPUTNAME << REGDESC.getX86Name(op->getReg()) << endl
#define CARG(n) OUTPUTNAME << "$" << n << ","
#define LCARG(n) OUTPUTNAME << "$" << n << endl

using namespace std;

class X86Generator
{
  private:
    ofstream OUTPUTNAME;
    RegisterDescriptor REGDESC;
    int jumpLabel;

    // To deal with cases like SUB a, b, a
    SymbolTableEntry phantomOp2;
    SymbolTableEntry phantomOp3;

    // Helper
    bool writeBinaryArithmeticOperation(OpCode op);
    bool writeBinaryRelationalOperation(OpCode op);
    bool generateRelopLabels(SymbolTableEntry* op1);

  public:
    SymbolTableEntry* dummyGetRegister(SymbolTableEntry* old);
    // Constructor and destructor for RAII
    X86Generator(const char* aFilename);
    ~X86Generator();
    bool WriteComment(string comment);
    // Nullary instructions
    bool WriteInstruction(OpCode op);

    // Special for CALL
    bool WriteInstruction(OpCode op, long op1);

    // Special for CALL
    bool WriteInstruction(OpCode op, string op1);

    // Unary instructions
    bool WriteInstruction(OpCode op, SymbolTableEntry* op1, long op2);
    bool WriteInstruction(OpCode op,
                          SymbolTableEntry* op1,
                          SymbolTableEntry* op2);

    // Binary instructions
    bool WriteInstruction(OpCode op, SymbolTableEntry* op1, long op2, long op3);
    bool WriteInstruction(OpCode op,
                          SymbolTableEntry* op1,
                          SymbolTableEntry* op2,
                          long op3);
    bool WriteInstruction(OpCode op,
                          SymbolTableEntry* op1,
                          SymbolTableEntry* op2,
                          SymbolTableEntry* op3);

    // Generate boilerplate and write instructions
    bool GenerateInstruction(Instruction& aInst);

    void MaybeWriteBack(Register aRegister);
    void LoadFromMemory(SymbolTableEntry* aSte);
    void MaybeGetRegister(SymbolTableEntry* aRegisterFor,
                          bool aLoadImmediately);
    void SynchronizeDescriptors(Register aRegister,
                                SymbolTableEntry* oldSymbol,
                                SymbolTableEntry* newSymbol);
    void WriteBackAll();
    void FlushRegisters();
};
