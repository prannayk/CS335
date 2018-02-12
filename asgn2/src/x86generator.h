#pragma once

#include <cassert>
#include <fstream>
#include <iostream>
#include <string>

#include "block.h"
#include "enums.h"
#include "ir.h"
#include "ir_lang.yy.h"
#include "registerdescriptor.h"

extern IR
load(int, char**);

#define LABELPREFIX "label"
#define OUTPUTNAME output
#define REGDESC regDesc
#define COMPARELABEL "cmpLabel"
#define PRINTLONGSTR "pstr"
#define INST(I) OUTPUTNAME << #I << "\t"
#define LINST(I) INST(I) << endl
#define ARG(op) OUTPUTNAME << REGDESC.getX86Name(op->getReg()) << ", "
#define LARG(op) OUTPUTNAME << REGDESC.getX86Name(op->getReg()) << endl
#define CARG(n) OUTPUTNAME << "$" << n << ","
#define LCARG(n) OUTPUTNAME << "$" << n << endl
#define LABL(lbl) OUTPUTNAME << LABELPREFIX << lbl << ":" << endl;
#define GLOBL(name) OUTPUTNAME << ".globl " << name << endl
#define FUNC(name) OUTPUTNAME << name << ": " << endl
#define REPORTERR(err)                                                         \
    cerr << "\033[1;31mError: \033[0m(" << __FUNCTION__ << ", " << __LINE__    \
         << "): " << err << endl;                                              \
    assert(0);                                                                 \
    return false;

using namespace std;

class X86Generator
{
  private:
    ofstream OUTPUTNAME;
    RegisterDescriptor REGDESC;
    int jumpLabel;
    Instruction currentInstruction;
    // To deal with cases like SUB a, b, a
    SymbolTableEntry phantomOp2;
    SymbolTableEntry phantomOp3;

    // Helper
    bool writeBinaryArithmeticOperation(OpCode op);
    bool writeBinaryRelationalOperation(OpCode op);
    bool writeUnaryArithmeticBitOperation(OpCode op);
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

    // Special for PRINT_LONG
    bool WriteInstruction(OpCode op, SymbolTableEntry* op1);

    // Special for CALL
    bool WriteInstruction(OpCode op, string op1);

    // Unary instructions
    bool WriteInstruction(OpCode op, SymbolTableEntry* op1, long op2);
    bool WriteInstruction(OpCode op,
                          SymbolTableEntry* op1,
                          SymbolTableEntry* op2);

    // Binary instructions
    SymbolTableEntry* getReg(SymbolTableEntry* entry);
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
    bool GenerateSimpleBlock(SimpleBlock& aSimpleBlock);
    bool GenerateComplexBlock(ComplexBlock& aComplexBlock);
    bool GenerateDataSection(SymbolTable& aSymbolTable,
                             SimpleBlock& aSimpleBlock);
    bool Generate(IR& aIR);

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
