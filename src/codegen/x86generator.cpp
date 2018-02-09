#include "x86generator.h"

X86Generator::X86Generator(const char* aFilename)
  : OUTPUTNAME(aFilename, ios::out | ios::trunc)
  , REGDESC()
  , jumpLabel(0)
{
}

X86Generator::~X86Generator()
{
    OUTPUTNAME.close();
}

bool
X86Generator::GenerateComment(string comment)
{
    OUTPUTNAME << "#" << comment << endl;
    return true;
}

bool
X86Generator::GenerateInstruction(OpCode op)
{
    if (op != RET) {
        return false;
    }
    LINST(ret);
    return true;
}

bool
X86Generator::GenerateInstruction(OpCode op, long op1)
{
    switch (op) {
        case CALL: {
            INST(call);
            break;
        }
        case GOTO: {
            INST(jmp);
            break;
        }
        default:
            return false;
    }
    OUTPUTNAME << LABELPREFIX << op1 << endl;
    return true;
}

bool
X86Generator::GenerateInstruction(OpCode op, SymbolTableEntry* op1, long op2)
{
    if (op1->getReg() == NONE) {
        return false;
    }

    if (op == LNOT) {
        // Short circuit if we get LNOT.
        INST(movq);
        CARG(!op2);
        LARG(op1);
        return true;
    }
    INST(movq);
    CARG(op2);
    LARG(op1);
    switch (op) {
        case ASG: {
            return true;
        }
        case NOT: {
            INST(notq);
            break;
        }
        case NEG: {
            INST(neg);
            break;
        }
        default: {
            return false;
        }
    }
    LARG(op1);
    return true;
}

bool
X86Generator::GenerateInstruction(OpCode op,
                                  SymbolTableEntry* op1,
                                  SymbolTableEntry* op2)
{
    if (op1->getReg() == NONE) {
        return false;
    }

    if (op == LNOT) {
        // Short circuit for LNOT.
        return GenerateInstruction(NEQ, op1, op2, 0L);
    }

    // Unary math/bit operations
    if (op >= 200 && op < 250) {
        INST(movq);
        ARG(op2);
        LARG(op1);
        switch (op) {
            case ASG: {
                return true;
            }
            case NOT: {
                INST(notq);
                break;
            }
            case NEG: {
                INST(neg);
                break;
            }
            default: {
                return false;
            }
        }
        LARG(op1);
        return true;
    }

    // Memory/vector ops
    // A writeback should be performed before using these instructions.
    if (op == GETADDR) {
        INST(leaq);
        // NOTE: Note this works because we only have a global table
        OUTPUTNAME << op2->getName();
        OUTPUTNAME << "(" << REGDESC.getX86Name(RIP) << "), ";
        LARG(op1);
        return true;
    }

    if (op == FOLLOWPTR) {
        INST(movq);
        OUTPUTNAME << "(" << REGDESC.getX86Name(op2->getReg()) << "), ";
        LARG(op1);
        return true;
    }

    return false;
}

bool
X86Generator::GenerateInstruction(OpCode op,
                                  SymbolTableEntry* op1,
                                  long op2,
                                  long op3)
{

    if (op1->getReg() == NONE) {
        return false;
    }

    // Binary control flow operation
    if (op == GOTOEQ) {
        INST(cmpq);
        CARG(op2);
        LARG(op1);
        INST(je);
        OUTPUTNAME << LABELPREFIX << op3 << endl;
    }

    // Binary math/bit operations
    if (op < 50) {
        INST(movq);
        CARG(op2);
        LARG(op1);

        if (op == DIV || op == MOD) {
            // This is not possible, since rem/idiv %reg needs at least
            // one register except %rax, which is op1.
            return false;
        }

        if (!writeBinaryArithmeticOperation(op)) {
            return false;
        }
        CARG(op3);
        LARG(op1);
        return true;
    }

    // Binary relops are not possible, since we need at least one
    // register for cmp besides op1 (in order for all the operations
    // to work fine) -- we can make some work like this.

    if (op >= 150 && op < 200) {
        // TODO: Add array accesses here.
        return true;
    }
    return false;
}

bool
X86Generator::GenerateInstruction(OpCode op,
                                  SymbolTableEntry* op1,
                                  SymbolTableEntry* op2,
                                  long op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE) {
        return false;
    }

    // Binary control flow operation
    if (op == GOTOEQ) {
        INST(cmpq);
        ARG(op2);
        LARG(op1);
        INST(je);
        OUTPUTNAME << LABELPREFIX << op3 << endl;
        return true;
    }

    // Binary math/bit operations
    if (op < 50) {
        // This is n math/bit operation
        // First, mov the operand to the dest
        INST(movq);
        ARG(op2);
        LARG(op1);

        if (op == DIV) {
            // Now, we assume certain things here which need to be true
            // RDX is available, and RAX is op1, and RDX is not op2
            if (op1->getReg() != RAX || op2->getReg() == RDX) {
                return false;
            }
            INST(xorq);
            OUTPUTNAME << "%rdx, %rdx" << endl;
            INST(movq);
            CARG(op3);
            LARG(op2);
            INST(idiv);
            LARG(op2);
            return true;
        }

        if (op == MOD) {
            // Now, we assume certain things here which need to be true
            // RDX is available, and RDX is op1, and RAX is not op1
            if (op1->getReg() != RDX || op2->getReg() == RAX) {
                return false;
            }
            INST(xorq);
            OUTPUTNAME << "%rdx, %rdx" << endl;
            INST(movq);
            CARG(op3);
            LARG(op2);
            INST(remq);
            LARG(op2);
            return true;
        }

        if (!writeBinaryArithmeticOperation(op)) {
            return false;
        }

        // Now, write the source and dest.
        CARG(op3);
        LARG(op1);
        return true;
    }

    // Binary relops.
    if (op >= 50 && op < 100) {
        INST(movq);
        CARG(op3);
        LARG(op1);

        INST(cmpq);
        ARG(op1);
        LARG(op2);

        if (!writeBinaryRelationalOperation(op)) {
            return false;
        }

        if (!generateRelopLabels(op1)) {
            return false;
        }

        return true;
    }

    // Binary memory/vector operations
    if (op >= 150 && op < 200) {
        // TODO: Add array accesses here.
        return true;
    }
    return false;
}

bool
X86Generator::GenerateInstruction(OpCode op,
                                  SymbolTableEntry* op1,
                                  SymbolTableEntry* op2,
                                  SymbolTableEntry* op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE ||
        op3->getReg() == NONE) {
        return false;
    }

    // Binary control flow operations.
    if (op == GOTOEQ) {
        // Label names cannot be STEs.
        return false;
    }

    // Binary math/bit operations
    if (op < 50) {
        // move the operand to the destination.
        INST(movq);
        ARG(op2);
        LARG(op1);

        if (op == DIV) {
            // Now, we assume certain things here which need to be true
            // RDX is available, and RAX is op1, and RDX is not op2/op3
            if (op1->getReg() != RAX || op2->getReg() == RDX ||
                op3->getReg() == RDX) {
                return false;
            }
            INST(xorq);
            OUTPUTNAME << "%rdx, %rdx" << endl;
            INST(idiv);
            LARG(op3);
            return true;
        }

        if (op == MOD) {
            // Now, we assume certain things here which need to be true
            // RAX is available, and RDX is op1, and RAX is not op2/op3
            if (op1->getReg() != RDX || op2->getReg() == RAX ||
                op3->getReg() == RAX) {
                return false;
            }
            INST(xorq);
            OUTPUTNAME << "%rdx, %rdx" << endl;
            INST(remq);
            LARG(op3);
            return true;
        }

        if (!writeBinaryArithmeticOperation(op)) {
            return false;
        }

        ARG(op3);
        LARG(op1);
        return true;
    }

    // Binary relops.
    if (op >= 50 && op < 100) {
        INST(cmpq);
        ARG(op3);
        LARG(op2);

        if (!writeBinaryRelationalOperation(op)) {
            return false;
        }

        if (!generateRelopLabels(op1)) {
            return false;
        }

        return true;
    }

    // Binary memory/vector operations
    if (op >= 150 && op < 200) {
        // TODO: Add array accesses here.
        return true;
    }

    return false;
}

bool
X86Generator::writeBinaryArithmeticOperation(OpCode op)
{
    switch (op) {
        case ADD: {
            INST(addq);
            break;
        }
        case SUB: {
            INST(subq);
            break;
        }
        case SL: {
            INST(shlq);
            break;
        }
        case SR: {
            INST(shrq);
            break;
        }
        case ASHR: {
            INST(sarq);
            break;
        }
        case AND: {
            INST(andq);
            break;
        }
        case OR: {
            INST(orq);
            break;
        }
        case XOR: {
            INST(xorq);
            break;
        }
        case MUL: {
            INST(imul);
            break;
        }
        default: {
            return false;
        }
    }
    return true;
}

bool
X86Generator::writeBinaryRelationalOperation(OpCode op)
{
    switch (op) {
        case GT:
            INST(jg);
            break;
        case LT:
            INST(jl);
            break;
        case GEQ:
            INST(jge);
            break;
        case LEQ:
            INST(jle);
            break;
        case EQ:
            INST(je);
            break;
        case NEQ:
            INST(jne);
            break;
        default:
            return false;
    }
    return true;
}

bool
X86Generator::generateRelopLabels(SymbolTableEntry* op1)
{
    int label1 = ++jumpLabel;
    int label2 = ++jumpLabel;

    OUTPUTNAME << COMPARELABEL << label1 << endl;
    INST(movq);
    CARG(0L);
    LARG(op1);
    INST(jmp);
    OUTPUTNAME << COMPARELABEL << label2 << endl;
    OUTPUTNAME << COMPARELABEL << label1 << ":" << endl;
    INST(movq);
    CARG(1L);
    LARG(op1);
    OUTPUTNAME << COMPARELABEL << label2 << ":" << endl;
    return true;
}
