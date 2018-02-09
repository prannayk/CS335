#pragma once

#include <fstream>
#include <iostream>
#include <string>

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

    // Helper
    bool writeBinaryArithmeticOperation(OpCode op);
    bool writeBinaryRelationalOperation(OpCode op);
    bool generateRelopLabels(SymbolTableEntry* op1);

  public:
    // Constructor and destructor for RAII
    X86Generator(const char* aFilename);
    ~X86Generator();
    bool GenerateComment(string comment);
    // Nullary instructions
    bool GenerateInstruction(OpCode op);

    // Single constant op instructions
    bool GenerateInstruction(OpCode op, long op1);

    // Unary instructions
    bool GenerateInstruction(OpCode op, SymbolTableEntry* op1, long op2);
    bool GenerateInstruction(OpCode op,
                             SymbolTableEntry* op1,
                             SymbolTableEntry* op2);

    // Binary instructions
    bool GenerateInstruction(OpCode op,
                             SymbolTableEntry* op1,
                             long op2,
                             long op3);
    bool GenerateInstruction(OpCode op,
                             SymbolTableEntry* op1,
                             SymbolTableEntry* op2,
                             long op3);
    bool GenerateInstruction(OpCode op,
                             SymbolTableEntry* op1,
                             SymbolTableEntry* op2,
                             SymbolTableEntry* op3);
};
