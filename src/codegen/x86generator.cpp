#include "x86generator.h"

X86Generator::X86Generator(const char* aFilename)
  : OUTPUTNAME(aFilename, ios::out | ios::trunc)
  , REGDESC()
  , jumpLabel(0)
  , phantomOp2("dnm2", INT)
  , phantomOp3("dnm3", INT)
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
X86Generator::WriteInstruction(OpCode op, SymbolTableEntry* op1, long op2)
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
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2)
{
    if (op1->getReg() == NONE) {
        return false;
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
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               long op2,
                               long op3)
{

    if (op1->getReg() == NONE) {
        return false;
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
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2,
                               long op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE) {
        return false;
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
            // URGENT TODO: MOD is faulty.
            INST(idiv); // Remainder.
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
X86Generator::WriteInstruction(OpCode op,
                               SymbolTableEntry* op1,
                               SymbolTableEntry* op2,
                               SymbolTableEntry* op3)
{
    if (op1->getReg() == NONE || op2->getReg() == NONE ||
        op3->getReg() == NONE) {
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
            INST(movq);
            // URGENT NOTE: MOD is faulty.
            INST(idiv); // Remainder
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
    AddressingMode v1a = aInst.getV1AddMode();
    AddressingMode v2a = aInst.getV2AddMode();
    AddressingMode v3a = aInst.getV3AddMode();

    // 0.1 Function calling/returning
    if (aInst.getOp() == CALL) {
        WriteBackAll();
        FlushRegisters();
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

    if (aInst.getOp() == RET) {
        WriteBackAll();
        FlushRegisters();

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

        LINST(retq);
        return true;
    }

    // 0.2 End of block instructions: GOTOEQ and GOTO
    // Not handled here, handled inside basic block loop.

    // 1 Binary instructions
    // 1.1 All three operands are registers
    if (numOps == 3 && v1a == REGISTER && v2a == REGISTER && v3a == REGISTER) {
        SymbolTableEntry* op1 = (SymbolTableEntry*)aInst.getV1();
        SymbolTableEntry* op2 = (SymbolTableEntry*)aInst.getV2();
        SymbolTableEntry* op3 = (SymbolTableEntry*)aInst.getV3();

        if (aInst.getOp() == DIV || aInst.getOp() == MOD) {
            // There is a point in every man's life where he has to say "fuck
            // efficiency", and come up with some inefficient, but correct shit.
            // This is that time.
            WriteBackAll();
            FlushRegisters();
            // Now, RDX, RAX, RCX are guaranteed empty.
            Register result = (aInst.getOp() == DIV) ? RAX : RDX;
            op1->setReg(result);
            REGDESC.setRegisterSTE(result, op1);
            SynchronizeDescriptors(result, NULL, op1);
            op1->setDirty(1);

            // Populate RBX, RCX but don't actually change regdesc or addrdesc
            // Reason: DIV a, a, a is problematic otherwise.
            if (op2->getName() != op1->getName()) {
                op2->setReg(RCX);
                REGDESC.setRegisterSTE(RCX, op2);
                SynchronizeDescriptors(RCX, NULL, op2);
                LoadFromMemory(op2);
            } else {
                LoadFromMemory(op1);
            }

            if (op3->getName() != op1->getName()) {
                op3->setReg(RBX);
                REGDESC.setRegisterSTE(RBX, op3);
                SynchronizeDescriptors(RBX, NULL, op3);
                LoadFromMemory(op3);
            } else {
                LoadFromMemory(op1);
            }

            return WriteInstruction(
              aInst.getOp(),
              op1,
              (op1->getName() == op2->getName()) ? op1 : op2,
              (op1->getName() == op3->getName()) ? op1 : op3);
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
            // There is a point in every man's life where he has to say "fuck
            // efficiency", and come up with some inefficient, but correct shit.
            // This is that time.
            WriteBackAll();
            FlushRegisters();
            // Now, RDX, RAX, RCX are guaranteed empty.
            Register result = (aInst.getOp() == DIV) ? RAX : RDX;
            op1->setReg(result);
            REGDESC.setRegisterSTE(result, op1);
            SynchronizeDescriptors(result, NULL, op1);
            op1->setDirty(1);

            // Reason: DIV a, a, NUM is problematic otherwise.
            if (op2->getName() != op1->getName()) {
                op2->setReg(RCX);
                REGDESC.setRegisterSTE(RCX, op2);
                SynchronizeDescriptors(RCX, NULL, op2);
                LoadFromMemory(op2);
                return WriteInstruction(aInst.getOp(), op1, op2, op3);
            }

            LoadFromMemory(op1);
            INST(movq);
            ARG(op1);
            OUTPUTNAME << phantomOp2.getName() << "(%rip)" << endl;
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
        return WriteInstruction(aInst.getOp(), op1, op2, op3);
    }

    // 1.3 We have something of the form %t1, NUM, %t2
    if (numOps == 3 && v1a == REGISTER && v2a == CONSTANT_VAL &&
        v3a == REGISTER) {
        // Not allowed.
        return false;
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
    return false;
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

/*
int
main()
{
    SymbolTableEntry* a = new SymbolTableEntry("a", INT);
    SymbolTableEntry* b = new SymbolTableEntry("b", INT);
    SymbolTableEntry* c = new SymbolTableEntry("c", INT);
    SymbolTableEntry* d = new SymbolTableEntry("d", INT);
    SymbolTableEntry* e = new SymbolTableEntry("e", INT);
    SymbolTableEntry* f = new SymbolTableEntry("f", INT);
    long l1 = 10L;
    X86Generator gen("testfile");
    Instruction i1(ADD, a, a, c, REGISTER, REGISTER, REGISTER, INT, INT, INT);
    Instruction i2(
      ADD, c, &l1, &l1, REGISTER, CONSTANT_VAL, CONSTANT_VAL, INT, INT, INT);
    Instruction i3(
      MOD, a, a, &l1, REGISTER, REGISTER, CONSTANT_VAL, INT, INT, INT);
    Instruction i4(LNOT, a, a, REGISTER, REGISTER, INT, INT);
    Instruction i5(
      CALL, (char*)"something", a, (AddressingMode)0, REGISTER, INT, INT);
    Instruction i6(RET, &l1, CONSTANT_VAL, INT);

    gen.GenerateInstruction(i4);
    gen.WriteBackAll();
    return 0;
}
*/
