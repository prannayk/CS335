#pragma once

#include "Node.h"
#include "Type.h"
#include "enums.h"
#include "ir.h"
#include <queue>
#include <vector>
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
#define REPORTERR(err)                                                         \
    cerr << "\033[1;31mError: \033[0m(" << __FUNCTION__ << ", " << __LINE__    \
         << "): " << err << endl;                                              \
    assert(0);                                                                 \

using namespace std;

class X86Generator{
 private:
  ST* globalTable;
  vector<Instruction*> instructionList;
  string text;
  int totalAllocatedSpace = 0; // Note: reset this at the start of every new func def
  string currentFName = "";
  map<string, ComplexBlock*> complexBlocks;
  RegisterDescriptor regDesc;
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
  STEntry* dummyGetRegister(STEntry* old);
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
