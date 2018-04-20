#pragma once

#include "Node.h"
#include "Type.h"
#include "enums.h"
#include "ir.h"
#include <queue>
#include <vector>
#include <algorithm>
#include <typeinfo>
#include <string.h>
#include <iostream>
#include <assert.h>

#define PTRSIZE 8
#define RBPSAVESPACE 8
#define FROMRBP(offset) to_string(- (offset) - RBPSAVESPACE) + "(%rbp)"
#define NUM(n) "$" + to_string(n)
#define INSTR0(v, I) v = v + "\n\t" + #I
#define INSTR1(v, I, o1) v = v + "\n\t" + #I + "\t" + o1
#define INSTR2(v, I, o1, o2) v = v + "\n\t" + #I + "\t" + o1 + ",\t" + o2
#define APPENDT(v, lit) v = v + "\n\t" + lit
#define APPEND(v, lit) v = v + "\n" + lit
#define STEREG(s) (this->regDesc.getX86Name(s->getReg()))
#define REPORTERR(err)                                                  \
  cerr << "\033[1;31mError: \033[0m(" << __FUNCTION__ << ", " << __LINE__ \
  << "): " << err << endl;                                              \
  assert(0);

#define ARITHINSTR2(v, operator, op3, op1)     \
  switch (operator) {                          \
  case ADD_OPER:                               \
    INSTR2(v, addq, op3, op1);                 \
    break;                                     \
  case SUB_OP:                                 \
    INSTR2(v, subq, op3, op1);                 \
    break;                                     \
  case SR_OP:                                  \
    INSTR2(v, shrq, op3, op1);                 \
    break;                                     \
  case SL_OP:                                  \
    INSTR2(v, shlq, op3, op1);                 \
    break;                                     \
  case ASHR_OP:                                \
    INSTR2(v, sarq, op3, op1);                 \
    break;                                     \
  case BAND_OP:                                \
    INSTR2(v, andq, op3, op1);                 \
    break;                                     \
  case BOR_OP:                                 \
    INSTR2(v, orq, op3, op1);                  \
    break;                                     \
  case XOR_OP:                                 \
    INSTR2(v, xorq, op3, op1);                 \
    break;                                     \
  case MUL_OPER:                               \
    INSTR2(v, imul, op3, op1);                 \
    break;                                     \
  default:                                     \
    REPORTERR("Unknown binary relop");         \
  }
#define UNARYINSTR2(v, operator, op1)           \
  switch (operator) {                           \
  case ASG:                                     \
    break;                                      \
  case NOT_OPER:                                \
    INSTR2(v, notq, op1, op1);                  \
    break;                                      \
  case NEG:                                     \
    INSTR2(v, neg, op1, op1);                   \
    break;                                      \
  case INC_OP:                                  \
    INSTR1(v, incq, op1);                       \
    break;                                      \
  case DEC_OP:                                  \
    INSTR1(v, decq, op1);                       \
    break;                                      \
  case COPY_OP:                                 \
    REPORTERR("Unimplemented COPY_OP");         \
  default:                                      \
    break;                                      \
  }
#define JUMPINSTR2(v, operator, label)          \
  switch (operator) {                           \
  case GT_OP:                                   \
    INSTR1(v, jg, label);                       \
    break;                                      \
  case LT_OP:                                   \
    INSTR1(v, jl, label);                       \
    break;                                      \
  case GEQ_OP:                                  \
    INSTR1(v, jge, label);                      \
    break;                                      \
  case LEQ_OP:                                  \
    INSTR1(v, jle, label);                      \
    break;                                      \
  case EQ_OP:                                   \
    INSTR1(v, je, label);                       \
    break;                                      \
  case NEQ_OP:                                  \
    INSTR1(v, jne, label);                      \
    break;                                      \
  }



using namespace std;

class X86Generator{
 private:
  ST* globalTable;
  vector<Instruction*> instructionList;
  string text;
  int totalAllocatedSpace = 0; // Note: reset this at the start of every new func def
  string currentFName = "";
  map<string, ComplexBlock*> complexBlocks;
  map<string, int> basicBlockMap;
  RegisterDescriptor regDesc;
  STEntry* dummyGetRegister(STEntry* old);
  void maybeGetRegisterIfNotConstant(void*, AddressingMode, bool);
 public:
  X86Generator(vector<Instruction*>, ST*);
  ST* Flatten(ST*);
  string Prolog();
  string Epilog();
  string StackAlloc();
  string Output() const { return this->text; }
  string GenerateFunctions();
  string GenerateFunction();
  string Generate();
  void GenerateSimpleBlock(SimpleBlock*);
  void MaybeWriteBack(Register aRegister);
  void LoadFromMemory(STEntry* aSte);
  void MaybeGetRegister(STEntry* aRegisterFor,
                        bool aLoadImmediately);
  void SynchronizeDescriptors(Register aRegister,
                              STEntry* oldSymbol,
                              STEntry* newSymbol);
  void WriteBackAll();
  void FlushRegisters();
};
