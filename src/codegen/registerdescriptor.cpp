#include "registerdescriptor.h"

RegisterDescriptor::RegisterDescriptor()
  : regDescTable()
{
}

void
RegisterDescriptor::setRegisterSTE(Register aReg, SymbolTableEntry* aSte)
{
    if (aReg == NONE || aReg == RSP || aReg == RBP) {
        // Cannot set these registers manually.
        return;
    }
    regDescTable[aReg] = aSte;
}

SymbolTableEntry*
RegisterDescriptor::getRegisterSTE(Register aReg)
{
    if ((aReg == NONE || aReg == RSP || aReg == RBP) ||
        !regDescTable.count(aReg)) {
        // If we try to access a disallowed or unassigned register
        return NULL;
    }
    return regDescTable[aReg];
}

string
RegisterDescriptor::getX86Name(Register aReg)
{
    switch (aReg) {
        case RBP:
            return "%rbp";
        case RSP:
            return "%rsp";
        case RAX:
            return "%rax";
        case RBX:
            return "%rbx";
        case RCX:
            return "%rcx";
        case RDX:
            return "%rdx";
        case RSI:
            return "%rsi";
        case RDI:
            return "%rdi";
        case R8:
            return "%r8";
        case R9:
            return "%r9";
        case R10:
            return "%r10";
        case R11:
            return "%r11";
        case R12:
            return "%r12";
        case R13:
            return "%r13";
        case R14:
            return "%r14";
        case R15:
            return "%r15";
        default:
            return NULL;
    }
}
