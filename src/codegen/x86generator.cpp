#include "x86generator.h"
#include <iostream>
using namespace std;

X86Generator::X86Generator(const char* aFilename)
  : OUTPUTNAME(aFilename, ios::out | ios::trunc)
  , REGDESC()
  , jumpLabel(0)
  , phantomOp2("dnm2", INT)
  , phantomOp3("dnm3", INT)
  , currentInstruction(NULL_IST)
{
}

X86Generator::~X86Generator()
{
    OUTPUTNAME.close();
}

bool
X86Generator::WriteComment(string comment)
{
    OUTPUTNAME << "#" << comment << endl;
    return true;
}

bool
X86Generator::WriteInstruction(OpCode op, SymbolTableEntry* op1)
{
    if (op != PRINT_LONG) {
        REPORTERR("Cannot find supported operation of the form (reg)");
    }

    // First, transfer the contents, if any, of rsi and rdi to a safe place.
    // We don't want to run the risk of allocating either rsi to store rdi
    // or vice versa, so be on the safe side.
    if (REGDESC.getRegisterSTE(RSI) != NULL ||
        REGDESC.getRegisterSTE(RDI) != NULL) {
        WriteBackAll();
        FlushRegisters();
    }

    INST(movq);
    OUTPUTNAME << op1->getName() << "(%rip), "
               << "%rsi" << endl;
    INST(leaq);
    OUTPUTNAME << PRINTLONGSTR << "(%rip), %rdi" << endl;
    INST(call);
    OUTPUTNAME << "printf@PLT" << endl;
    return true;
}

bool
X86Generator::WriteInstruction(OpCode op, SymbolTableEntry* op1, long op2)
{
    if (op1->getReg() == NONE) {
        REPORTERR("Operand has NONE register.")
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
    writeUnaryArithmeticBitOperation(op);
    if (op != ASG) {
        LARG(op1);
    }
    return true;
}

bool
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2)
{
    if (op1->getReg() == NONE) {
        REPORTERR("Operand has NONE register.")
    }

    if (op == LNOT) {
        // Short circuit for LNOT.
        return WriteInstruction(XOR, op1, op2, 1L);
    }

    // Unary math/bit operations
    if (op >= 200 && op < 250) {
        INST(movq);
        ARG(op2);
        LARG(op1);
        writeUnaryArithmeticBitOperation(op);
        if (op != ASG) {
            LARG(op1);
        }
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

    REPORTERR("Cannot find supported operation of the form reg, reg");
}

bool
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               long op2,
                               long op3)
{

    if (op1->getReg() == NONE) {
        REPORTERR("Operand has NONE register");
    }

    if (op == GOTOEQ) {
        INST(cmpq);
        CARG(op2);
        LARG(op1);
        INST(je);
        OUTPUTNAME << LABELPREFIX << op3 << endl;
        return true;
    }

    // Binary math/bit operations
    if (op < 50) {
        INST(movq);
        CARG(op2);
        LARG(op1);

        if (op == DIV || op == MOD) {
            // This is not possible, since rem/idiv %reg needs at least
            // one register except %rax, which is op1.
            REPORTERR("Division and mod is not possible with reg, num, num");
        }

        writeBinaryArithmeticOperation(op);

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
    REPORTERR("Cannot find supported operation of the form reg, num, num");
}

bool
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2,
                               long op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE) {
        REPORTERR("Operand has NONE register.");
    }

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
                REPORTERR("Division registers are wrong");
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
            REPORTERR("Mod should be handled by division");
        }

        writeBinaryArithmeticOperation(op);

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

        writeBinaryRelationalOperation(op);

        generateRelopLabels(op1);

        return true;
    }

    // Binary memory/vector operations
    if (op >= 150 && op < 200) {
        // TODO: Add array accesses here.
        return true;
    }
    REPORTERR("Cannot find supported operation of the form reg, reg, num");
}

bool
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2,
                               SymbolTableEntry* op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE ||
        op3->getReg() == NONE) {
        REPORTERR("Operands have NONE register");
    }

    // Binary math/bit operations
    if (op < 50) {
        if (op == DIV) {
            // Now, we assume certain things here which need to be true
            // RDX is available, and RAX is op1, and RDX is not op2/op3
            if (op1->getReg() != RAX || op2->getReg() == RDX ||
                op3->getReg() == RDX) {
                REPORTERR("Division registers error");
            }
            INST(xorq);
            OUTPUTNAME << "%rdx, %rdx" << endl;
            INST(idiv);
            LARG(op3);
            return true;
        }
        // move the operand to the destination.
        INST(movq);
        ARG(op2);
        LARG(op1);

        if (op == MOD) {
            REPORTERR("Mod instructions should be handled by division");
        }

        writeBinaryArithmeticOperation(op);

        ARG(op3);
        LARG(op1);
        return true;
    }

    // Binary relops.
    if (op >= 50 && op < 100) {
        INST(cmpq);
        ARG(op3);
        LARG(op2);

        writeBinaryRelationalOperation(op);

        generateRelopLabels(op1);

        return true;
    }

    // Binary memory/vector operations
    if (op >= 150 && op < 200) {
        // TODO: Add array accesses here.
        return true;
    }

    REPORTERR("Supported operation of the form reg, reg, reg does not exist");
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
            REPORTERR("Cannot find binary arithmetic operation");
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
            REPORTERR("Cannot find binary relop");
    }
    return true;
}

bool
X86Generator::writeUnaryArithmeticBitOperation(OpCode op)
{
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
        }
    }
    REPORTERR("Cannot find supported operation of form reg, const");
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

SymbolTableEntry*
X86Generator::dummyGetRegister(SymbolTableEntry* old)
{
    static int regn = -1;
    regn = (regn + 1) % 3;

    old->setReg((Register)(regn + 1));
    return REGDESC.getRegisterSTE((Register)(regn + 1));
}

bool
X86Generator::GenerateInstruction(Instruction& aInst)
{
    int numOps = aInst.getNumOps();
    OpCode op = aInst.getOp();
    AddressingMode v1a = aInst.getV1AddMode();
    AddressingMode v2a = aInst.getV2AddMode();
    AddressingMode v3a = aInst.getV3AddMode();

    // 0 Control flow/special instructions
    {
        if (op == PRINT_LONG) {
            return WriteInstruction(PRINT_LONG,
                                    (SymbolTableEntry*)aInst.getV1());
        }

        if (op == CALL || op == RET || op == GOTOEQ || op == GOTO) {
            WriteBackAll();
            FlushRegisters();
        }
        // 0.1 Function calling/returning
        if (op == CALL) {
            // With call, the first op is a string
            char* functionName = (char*)aInst.getV1();
            INST(call);
            OUTPUTNAME << functionName << endl;

            // The second op has to be an identifier, which stores the return.
            // The contents of the identifier are written back and flushed.
            SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV2();
            INST(movq);
            OUTPUTNAME << "%rax, " << op1->getName() << "(%rip)" << endl;
            return true;
        }

        if (op == RET) {
            // With return, we might want to return an identifier or a 0
            if (v1a == CONSTANT_VAL) {
                INST(movq);
                CARG(0L);
                OUTPUTNAME << "%rax" << endl;
            } else {
                SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
                INST(movq);
                OUTPUTNAME << op1->getName() << "(%rip), %rax" << endl;
            }

            INST(movq);
            OUTPUTNAME << "%rbp, %rsp" << endl;
            INST(popq);
            OUTPUTNAME << "%rbp" << endl;
            LINST(retq);
            return true;
        }

        if (op == GOTO) {
            long label = *(long*)aInst.getV1();
            INST(jmp);
            OUTPUTNAME << LABELPREFIX << label << endl;
            return true;
        }

        if (op == GOTOEQ) {
            long label = *(long*)aInst.getV1();

            if (aInst.getV3AddMode() == REGISTER) {
                SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
                SymbolTableEntry* op3 = (SymbolTableEntry*)aInst.getV3();
                MaybeGetRegister(op2, true);
                MaybeGetRegister(op3, true);
                return WriteInstruction(GOTOEQ, op2, op3, label);
            }
            SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
            MaybeGetRegister(op2, true);
            return WriteInstruction(GOTOEQ, op2, *(long*)aInst.getV3(), label);
        }
    }

    // 1 Binary instructions
    // 1.1 All three operands are registers
    if (numOps == 3 && v1a == REGISTER && v2a == REGISTER && v3a == REGISTER) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
        SymbolTableEntry* op3 = (SymbolTableEntry*)aInst.getV3();

        if (aInst.getOp() == DIV || aInst.getOp() == MOD) {
            // Division is super hard, so we only accept divisions in just one
            // form: A = A / B
            // All other divisions are converted to such a form.

            // Case: A = B / B
            if (op2->getName() == op3->getName()) {
                // The result will either be a 0 or a 1.
                long result = (aInst.getOp() == DIV) ? 1L : 0L;
                Instruction i(
                  ASG, op1, &result, REGISTER, CONSTANT_VAL, INT, INT);
                return GenerateInstruction(i);
            }

            // Modulus is actually carried out by idiv
            if (aInst.getOp() == MOD) {
                Instruction i(DIV,
                              op1,
                              op2,
                              op3,
                              REGISTER,
                              REGISTER,
                              REGISTER,
                              INT,
                              INT,
                              INT);
                GenerateInstruction(i);
                // Now, our result will be stored in RDX.
                INST(movq);
                OUTPUTNAME << "%rdx, " << op1->getName() << "(%rip)" << endl;
                // Update the tables to reflect this.
                op1->setReg(RDX);
                REGDESC.setRegisterSTE(RDX, op1);
                REGDESC.setRegisterSTE(RAX, NULL);
                return true;
            }

            // Case: A = B / A (Trickiest case)
            if (op1->getName() == op3->getName()) {
                Instruction i(
                  ASG, &phantomOp2, op1, REGISTER, REGISTER, INT, INT);
                GenerateInstruction(i);
                Instruction j(ASG, op1, op2, REGISTER, REGISTER, INT, INT);
                GenerateInstruction(i);
                Instruction k(DIV,
                              op1,
                              op2,
                              &phantomOp2,
                              REGISTER,
                              REGISTER,
                              REGISTER,
                              INT,
                              INT,
                              INT);
                return GenerateInstruction(k);
            }

            // Case: A = B / C
            if (op1->getName() != op2->getName()) {
                Instruction i(ASG, op1, op2, REGISTER, REGISTER, INT, INT);
                GenerateInstruction(i);
                Instruction j(DIV,
                              op1,
                              op1,
                              op3,
                              REGISTER,
                              REGISTER,
                              REGISTER,
                              INT,
                              INT,
                              INT);
                return GenerateInstruction(j);
            }

            // Case: A = A / B
            assert(op1->getName() == op2->getName());
            assert(op2->getName() != op3->getName());

            WriteBackAll();
            FlushRegisters();
            // Now, RDX, RAX, RCX are guaranteed empty.
            Register result = RAX;
            op1->setReg(result);
            REGDESC.setRegisterSTE(result, op1);
            SynchronizeDescriptors(result, NULL, op1);
            LoadFromMemory(op1);

            op3->setReg(RBX);
            REGDESC.setRegisterSTE(RBX, op3);
            SynchronizeDescriptors(RBX, NULL, op3);
            LoadFromMemory(op3);

            op1->setDirty(1);
            return WriteInstruction(DIV, op1, op1, op3);
            // (op1->getName() == op2->getName()) ? op1 : op2,
            // (op1->getName() == op3->getName()) ? op1 : op3);
        }

        if (op1->getName() == op3->getName()) {
            MaybeWriteBack(op3->getReg());
            MaybeGetRegister(&phantomOp3, false);
            INST(movq);
            OUTPUTNAME << op3->getName() << "(%rip), ";
            OUTPUTNAME << REGDESC.getX86Name(phantomOp3.getReg()) << endl;
            Instruction i(aInst.getOp(),
                          op1,
                          op2,
                          &phantomOp3,
                          REGISTER,
                          REGISTER,
                          REGISTER,
                          INT,
                          INT,
                          INT);
            return GenerateInstruction(i);
        }

        if (op1->getName() == op2->getName()) {
            MaybeWriteBack(op2->getReg());
            MaybeGetRegister(&phantomOp2, false);
            INST(movq);
            OUTPUTNAME << op2->getName() << "(%rip), ";
            OUTPUTNAME << REGDESC.getX86Name(phantomOp2.getReg()) << endl;
            Instruction i(aInst.getOp(),
                          op1,
                          &phantomOp2,
                          op3,
                          REGISTER,
                          REGISTER,
                          REGISTER,
                          INT,
                          INT,
                          INT);
            return GenerateInstruction(i);
        }

        MaybeGetRegister(op2, true);
        MaybeGetRegister(op3, true);
        MaybeGetRegister(op1, false);
        op1->setDirty(1);
        return WriteInstruction(aInst.getOp(), op1, op2, op3);
    }

    // 1.2 We have something of the form %t1, %t2, NUM
    if (numOps == 3 && v1a == REGISTER && v2a == REGISTER &&
        v3a == CONSTANT_VAL) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
        long op3 = *(long*)aInst.getV3();

        if (aInst.getOp() == DIV || aInst.getOp() == MOD) {
            // Division is super hard, so we convert all division to take the
            // form A = A / NUM.

            // Case A = B / NUM
            if (op1->getName() != op2->getName()) {
                Instruction i(ASG, op1, op2, REGISTER, REGISTER, INT, INT);
                GenerateInstruction(i);
                Instruction j(DIV,
                              op1,
                              op1,
                              &op3,
                              REGISTER,
                              REGISTER,
                              CONSTANT_VAL,
                              INT,
                              INT,
                              INT);
                return GenerateInstruction(j);
            }

            // Modulus is actually carried out by idiv
            if (aInst.getOp() == MOD) {
                Instruction i(DIV,
                              op1,
                              op2,
                              &op3,
                              REGISTER,
                              REGISTER,
                              CONSTANT_VAL,
                              INT,
                              INT,
                              INT);
                GenerateInstruction(i);
                // Now, our result will be stored in RDX.
                INST(movq);
                OUTPUTNAME << "%rdx, " << op1->getName() << "(%rip)" << endl;
                // Update the tables to reflect this.
                op1->setReg(RDX);
                REGDESC.setRegisterSTE(RDX, op1);
                REGDESC.setRegisterSTE(RAX, NULL);
                return true;
            }

            // Case A = A / NUM
            WriteBackAll();
            FlushRegisters();
            assert(op1->getName() == op2->getName());
            // Now, RDX, RAX, RCX are guaranteed empty.
            Register result = RAX;
            op1->setReg(result);
            REGDESC.setRegisterSTE(result, op1);
            SynchronizeDescriptors(result, NULL, op1);
            LoadFromMemory(op1);

            op1->setDirty(1);
            return WriteInstruction(DIV, op1, op1, op3);
        }

        if (op1->getName() == op2->getName()) {
            MaybeWriteBack(op2->getReg());
            MaybeGetRegister(&phantomOp2, false);
            INST(movq);
            OUTPUTNAME << op2->getName() << "(%rip), ";
            OUTPUTNAME << REGDESC.getX86Name(phantomOp2.getReg()) << endl;
            Instruction i(aInst.getOp(),
                          op1,
                          &phantomOp2,
                          &op3,
                          REGISTER,
                          REGISTER,
                          CONSTANT_VAL,
                          INT,
                          INT,
                          INT);
            return GenerateInstruction(i);
        }

        MaybeGetRegister(op2, true);
        MaybeGetRegister(op1, false);
        op1->setDirty(1);
        return WriteInstruction(aInst.getOp(), op1, op2, op3);
    }

    // 1.3 We have something of the form %t1, NUM, %t2
    if (numOps == 3 && v1a == REGISTER && v2a == CONSTANT_VAL &&
        v3a == REGISTER) {
        // Not allowed.
        REPORTERR("Unallowed operation of type reg, num, reg");
    }

    // 1.4 We have something of the form %t1, NUM, NUM
    if (numOps == 3 && v1a == REGISTER && v2a == CONSTANT_VAL &&
        v3a == CONSTANT_VAL) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        long op2 = *(long*)aInst.getV2();
        long op3 = *(long*)aInst.getV3();

        MaybeGetRegister(op1, false);
        op1->setDirty(1);
        return WriteInstruction(aInst.getOp(), op1, op2, op3);
    }

    // 2 Unary operations
    // 2.1 Unary operations of the form %t1, %t2
    if (numOps == 2 && v1a == REGISTER && v2a == REGISTER) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
        // TOOD: Evaluate the need for this set dirty.
        op1->setDirty(1);

        if (op1->getName() == op2->getName()) {
            MaybeGetRegister(&phantomOp2, false);
            INST(movq);
            OUTPUTNAME << op1->getName() << "(%rip), ";
            OUTPUTNAME << REGDESC.getX86Name(phantomOp2.getReg()) << endl;
            Instruction i(
              aInst.getOp(), op1, &phantomOp2, REGISTER, REGISTER, INT, INT);
            return GenerateInstruction(i);
        }

        MaybeGetRegister(op2, true);
        MaybeGetRegister(op1, false);
        op1->setDirty(1);
        return WriteInstruction(aInst.getOp(), op1, op2);
    }

    // 2.2 Unary operations of the form %t1, NUM
    if (numOps == 2 && v1a == REGISTER && v2a == CONSTANT_VAL) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        long op2 = *(long*)aInst.getV2();

        MaybeGetRegister(op1, false);
        op1->setDirty(1);
        return WriteInstruction(aInst.getOp(), op1, op2);
    }
    REPORTERR("Instruction is unsupported");
}

void
X86Generator::MaybeWriteBack(Register aRegister)
{
    SymbolTableEntry* ste;
    if ((ste = REGDESC.getRegisterSTE(aRegister)) == NULL ||
        // Can't writeback nothing or if already written back.
        ste->getDirty() == 0) {
        return;
    }

    INST(movq);
    ARG(ste);
    OUTPUTNAME << ste->getName() << "(%rip)" << endl;

    ste->setDirty(0);
}

void
X86Generator::LoadFromMemory(SymbolTableEntry* aSte)
{
    if (aSte == NULL || aSte->getReg() == NONE ||
        aSte != REGDESC.getRegisterSTE(aSte->getReg())) {
        // Can'load from nothing, can't load into if register is
        // not owned by STE.
        return;
    }

    INST(movq);
    OUTPUTNAME << aSte->getName() << "(%rip), ";
    LARG(aSte);

    // Freshly loaded data is not dirty.
    aSte->setDirty(0);
}

void
X86Generator::MaybeGetRegister(SymbolTableEntry* aRegisterFor,
                               bool aLoadImmediately)
{
    if (aRegisterFor->getReg() == NONE) {
        SymbolTableEntry* oldSymbolForRegister = dummyGetRegister(aRegisterFor);
        assert(aRegisterFor->getReg() != NONE);

        // Write back if needed.
        if (oldSymbolForRegister != NULL) {
            MaybeWriteBack(oldSymbolForRegister->getReg());
        }

        // Make sure the descriptors look as they should.
        SynchronizeDescriptors(
          aRegisterFor->getReg(), oldSymbolForRegister, aRegisterFor);

        if (aLoadImmediately) {
            // This needs to be done only when we didn't have a register,
            // since otherwise we don't need to load from memory.
            // In fact we should not, since the value in register
            // will be more recent than that in memory.
            LoadFromMemory(aRegisterFor);
        }
    }
}

void
X86Generator::SynchronizeDescriptors(Register aRegister,
                                     SymbolTableEntry* oldSymbol,
                                     SymbolTableEntry* newSymbol)
{
    if (oldSymbol != NULL) {
        assert(oldSymbol->getReg() == aRegister);
        oldSymbol->setReg(NONE);
        oldSymbol->setDirty(0);
    }

    assert(newSymbol->getReg() == aRegister);
    REGDESC.setRegisterSTE(aRegister, newSymbol);
    newSymbol->setDirty(0);
}

void
X86Generator::WriteBackAll()
{
    // Note: this depends on the enums being sequential.
    for (int r = RAX; r <= R15; r++) {
        MaybeWriteBack((Register)r);
    }
}

void
X86Generator::FlushRegisters()
{
    for (int r = RAX; r <= R15; r++) {
        SymbolTableEntry* ste = REGDESC.getRegisterSTE((Register)r);
        if (ste != NULL) {
            // We need to clear this up, writeback has been called before.
            assert(ste->getDirty() == 0);
            ste->setReg(NONE);
            REGDESC.setRegisterSTE((Register)r, NULL);
        }
    }
}

SymbolTableEntry*
X86Generator::getReg(SymbolTableEntry* entry)
{
    SymbolTableEntry* a;
    Register r;
    if (entry == currentInstruction.getV1())
        r = currentInstruction.getV1Register();
    if (entry == currentInstruction.getV2())
        r = currentInstruction.getV2Register();
    if (entry == currentInstruction.getV3())
        r = currentInstruction.getV3Register();
    /* if (r < (Register)0){ printf("Error : can not find register\n");
     * exit(EXIT_FAILURE); } */
    a = REGDESC.getRegisterSTE(r);
    REGDESC.setRegisterSTE(r, entry);
    return a;
}

bool
X86Generator::GenerateSimpleBlock(SimpleBlock& aSimpleBlock)
{
    LABL(aSimpleBlock.getLabel());
    SimpleBlock* next = aSimpleBlock.getNextBlock();
    vector<Instruction*>::iterator iter;

    Instruction* current;
    for (iter = aSimpleBlock.instructions.begin();
         iter != aSimpleBlock.instructions.end();
         iter++) {
        current = *iter;
        GenerateInstruction(*current);
        if (current->getOp() == GOTO || current->getOp() == GOTOEQ) {
            // Do stuff
            break;
        }
    }

    if (next != NULL) {
        long nextLabel = next->getLabel();
        WriteBackAll();
        FlushRegisters();
        current = new Instruction(GOTO, &nextLabel, CONSTANT_VAL, INT);
        GenerateInstruction(*current);
    }

    return true;
}

bool
X86Generator::GenerateComplexBlock(ComplexBlock& aComplexBlock)
{
    long firstBlockLabel = aComplexBlock.getFirstBlock();
    GLOBL(aComplexBlock.getLabel());
    FUNC(aComplexBlock.getLabel());

    // Function PROLOG
    INST(pushq);
    OUTPUTNAME << "%rbp" << endl;
    INST(movq);
    OUTPUTNAME << "%rsp, %rbp" << endl;

    Instruction start(GOTO, &firstBlockLabel, CONSTANT_VAL, INT);
    GenerateInstruction(start);

    map<int, SimpleBlock*>::iterator iter;

    SimpleBlock* current;
    for (iter = aComplexBlock.blocks.begin();
         iter != aComplexBlock.blocks.end();
         iter++) {
        current = iter->second;
        GenerateSimpleBlock(*current);
    }
    return true;
}

int
main()
{
    SymbolTableEntry* a = new SymbolTableEntry("a", INT);
    SymbolTableEntry* b = new SymbolTableEntry("b", INT);
    SymbolTableEntry* c = new SymbolTableEntry("c", INT);
    long one = 1L;
    long three = 3L;
    long seven = 7L;
    long five = 5L;
    long label1 = 1L;
    long label2 = 2L;
    long label3 = 3L;
    long label4 = 4L;
    long label5 = 5L;
    X86Generator gen("testfile");

    ComplexBlock chaitanyaBhagwat((char*)"main", 1);
    SimpleBlock mySb1(1, NULL);
    SimpleBlock mySb2(2, NULL);
    SimpleBlock mySb3(3, NULL);
    SimpleBlock mySb4(4, NULL);
    SimpleBlock mySb5(5, NULL);

    vector<Instruction*> inst1;
    vector<Instruction*> inst2;
    vector<Instruction*> inst3;
    vector<Instruction*> inst4;
    vector<Instruction*> inst5;

    inst1.push_back(
      new Instruction(ASG, a, &five, REGISTER, CONSTANT_VAL, INT, INT));
    inst1.push_back(new Instruction(
      GT, b, a, &three, REGISTER, REGISTER, CONSTANT_VAL, INT, INT, INT));
    inst1.push_back(new Instruction(GOTOEQ,
                                    &label2,
                                    b,
                                    &one,
                                    CONSTANT_VAL,
                                    REGISTER,
                                    CONSTANT_VAL,
                                    INT,
                                    INT,
                                    INT));
    inst5.push_back(new Instruction(GOTO, &label3, CONSTANT_VAL, INT));

    inst2.push_back(new Instruction(ASG, c, a, REGISTER, REGISTER, INT, INT));
    inst2.push_back(new Instruction(GOTO, &label4, CONSTANT_VAL, INT));

    inst3.push_back(
      new Instruction(ASG, c, &seven, REGISTER, CONSTANT_VAL, INT, INT));

    inst4.push_back(new Instruction(PRINT_LONG, a, CONSTANT_VAL, INT));
    inst4.push_back(new Instruction(RET, &seven, CONSTANT_VAL, INT));

    mySb1.instructions = inst1;
    mySb2.instructions = inst2;
    mySb3.instructions = inst3;
    mySb4.instructions = inst4;
    mySb5.instructions = inst5;

    mySb1.setNextBlock(&mySb5);
    mySb2.setNextBlock(&mySb3);
    mySb3.setNextBlock(&mySb4);
    mySb5.setNextBlock(&mySb2);

    chaitanyaBhagwat.addBlock(&mySb1);
    chaitanyaBhagwat.addBlock(&mySb5);
    chaitanyaBhagwat.addBlock(&mySb2);
    chaitanyaBhagwat.addBlock(&mySb3);
    chaitanyaBhagwat.addBlock(&mySb4);

    gen.GenerateComplexBlock(chaitanyaBhagwat);

    return 0;
}
