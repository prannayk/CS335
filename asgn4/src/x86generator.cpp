#include "x86generator.h"

X86Generator::X86Generator(vector<Instruction*> aInstructionList,
                           ST* aGlobalTable)
  : globalTable(aGlobalTable)
  , instructionList(aInstructionList)
  , currentFName("main") // remember to fix this
  , regDesc()
{}

string
X86Generator::StackAlloc()
{

    // 1. Allocate space on stack for temps
    // 2. Allocate space on heap for arrays and structs
    // 3. Transfer arguments from registers to newly allocated space.

    ST* fnTable = ST::funcSTs[this->currentFName];
    string malloced = "";
    vector<STEntry*> deferredMallocs;
    int totalSpace = 0;
    // Generate the stack allocation code for the current symbol table.
    queue<ST*> sts;
    sts.push(fnTable);

    // Start BFS through the table.
    while (!sts.empty()) {
        ST* s = sts.front();
        sts.pop();

        if (s == nullptr) {
            // This should, ideally, not happen.
            continue;
        }
        for (auto s1 : s->children) {
            sts.push(s1);
        }

        for (auto x : s->table) {
            STEntry* s1 = x.second;
            s1->setReg(NONE);
            s1->offset = totalSpace;
            if (s1->getType()->GetTypeClass() == 5 ||
                s1->getType()->GetTypeClass() == 4) {
                // This is a struct or an array, so deal with it by mallocing
                // and storing a pointer. We shall defer this to after this
                // whole BFS, because we might need to use the registers edi and
                // eax, which might be occupied at this point
                totalSpace += PTRSIZE;
                deferredMallocs.push_back(s1);
            } else {
                // Note that any register is located at
                // -(offset + RBPSaveSpace) from rbp
                // RBPSaveSpace = 8 for x64
                totalSpace += s1->getType()->mem_size;
            }
        }
    }

    // Move arguments to their designated places
    vector<string> args = ST::funcParamNamesInOrder[this->currentFName];
    auto argSize = args.size();

    // Any argument after the 6th one is on the stack
    for (auto i = 6; i < argSize; i++) {
        string arg = args[i];
        STEntry* d = fnTable->getVar(arg);
        // The arguments can be indexed wrt RBP, but we need to leave space for
        // the saved RBP and the return pointer. RCX is used by clang for the
        // swap operation so I am following that.
        int aboveRBP = (PTRSIZE * 2) + (i - 6) * PTRSIZE;
        INSTR2(malloced, movq, to_string(aboveRBP) + "(%rbp)", "%rcx");
        INSTR2(malloced, movq, "%rcx", FROMRBP(d->offset));
    }

    // For the next block to work if argSize > 6
    if (argSize > 6) {
        argSize = 6;
    }

    // The fallthrough here is intentional
    switch (argSize) {
        STEntry* d;
        case 6:
            d = fnTable->getVar(args[5]);
            INSTR2(malloced, movq, "%r9", FROMRBP(d->offset));
        case 5:
            d = fnTable->getVar(args[4]);
            INSTR2(malloced, movq, "%r8", FROMRBP(d->offset));
        case 4:
            d = fnTable->getVar(args[3]);
            INSTR2(malloced, movq, "%rcx", FROMRBP(d->offset));
        case 3:
            d = fnTable->getVar(args[2]);
            INSTR2(malloced, movq, "%rdx", FROMRBP(d->offset));
        case 2:
            d = fnTable->getVar(args[1]);
            INSTR2(malloced, movq, "%rsi", FROMRBP(d->offset));
        case 1:
            d = fnTable->getVar(args[0]);
            INSTR2(malloced, movq, "%rdi", FROMRBP(d->offset));
        case 0:
            // No arguments
            break;
    }

    // Deferred mallocs are actually executed
    for (auto d : deferredMallocs) {
        INSTR2(malloced, movl, NUM(d->getType()->mem_size), "%edi");
        INSTR1(malloced, callq, "malloc@PLT");
        INSTR2(malloced, movq, "%rax", FROMRBP(d->offset));
    }

    this->totalAllocatedSpace = totalSpace;
    return malloced;
}

string
X86Generator::Prolog()
{
    // The Prolog does the following:
    // 1. Fix stack base and top.
    // 2. Save any callee saved registers. (Not to do, because we will write
    // back all anyway while calling a function)
    string prolog = ".globl " + this->currentFName;
    APPEND(prolog, this->currentFName + ":");
    INSTR1(prolog, pushq, "%rbp");
    INSTR2(prolog, movq, "%rsp", "%rbp");
    INSTR2(prolog, subq, NUM(this->totalAllocatedSpace), "%rsp");
    return prolog;
}

string
X86Generator::Epilog()
{
    string epilog = "\nepilog" + this->currentFName + ":";
    INSTR2(epilog, addq, NUM(this->totalAllocatedSpace), "%rsp");
    INSTR1(epilog, popq, "%rbp");
    INSTR0(epilog, retq);
    return epilog;
}

string
X86Generator::GenerateFunctions()
{
    string gen = "";
    string s, p, e, fncode;
    for (auto f : ST::funcDefs) {
        this->currentFName = f.first;
        this->totalAllocatedSpace = 0;
        // This order matters, because p depends on s's side effect.
        s = this->StackAlloc();
        p = this->Prolog();
        e = this->Epilog();
        fncode = this->GenerateFunction();
        gen += p + s + fncode + e + "\n";
    }
    return gen;
}

string
X86Generator::GenerateFunction()
{
    string genSt = "";
    if (this->complexBlocks.count(this->currentFName) == 0) {
        REPORTERR("Complex block does not exist for a function");
    }
    ComplexBlock* cb = this->complexBlocks[this->currentFName];
    for (auto sbkey : cb->blocks) {
        // Iterate over, and generate all the simple blocks.
        SimpleBlock* sb = sbkey.second;
        APPEND(genSt, ("labelm" + to_string(sb->getLabel()) + ":"));
        this->text = "";
        GenerateSimpleBlock(sb);
        genSt += this->text;
    }
    return genSt;
}

string
memoryOrConstant(void* op, AddressingMode a)
{
    if (a == REGISTER) {
        STEntry* s = (STEntry*)op;
        return FROMRBP(s->offset);
    } else if (a == CONSTANT_VAL) {
        long l = *(long*)op;
        return NUM(l);
    }
    REPORTERR("Operand was not memoryOrConstant");
    return "";
}

string
registerOrConstant(void* op, AddressingMode a)
{
    if (a == CONSTANT_VAL) {
        long l = *(long*)op;
        return NUM(l);
    }

    if (a != REGISTER) {
        REPORTERR("Operand was not registerOrConstant");
        return "";
    }
    STEntry* ste = (STEntry*)op;
    return RegisterDescriptor::getX86Name(ste->getReg());
}

enum ArithmeticInstructionType
{
    ABC,
    AAB,
    ABA,
    ABB,
    AAA
};

ArithmeticInstructionType
arithmeticInstructionType(Instruction* aInstruction)
{
    auto op1 = aInstruction->getV1();
    auto op2 = aInstruction->getV2();
    auto op3 = aInstruction->getV3();
    if (op1 == op2 && op2 == op3) {
        return AAA;
    }
    if (op1 == op3 && op1 != op2) {
        return ABA;
    }
    if (op1 == op2 && op1 != op3) {
        return AAB;
    }
    if (op2 == op3 && op1 != op2) {
        return ABB;
    }
    return ABC;
}

enum UnaryInstructionType
{
    AA,
    AB
};

UnaryInstructionType
unaryInstructionType(Instruction* aInstruction)
{
    auto op1 = aInstruction->getV1();
    auto op2 = aInstruction->getV2();
    if (op1 == op2) {
        return AA;
    }
    return AB;
}

void
X86Generator::maybeGetRegisterIfNotConstant(void* op,
                                            AddressingMode a,
                                            bool aLoadImmediately)
{
    if (a != REGISTER) {
        return;
    }
    STEntry* ste = (STEntry*)op;
    MaybeGetRegister(ste, aLoadImmediately);
}

void
X86Generator::GenerateSimpleBlock(SimpleBlock* aSb)
{
    bool functionCallMode = false;
    int numParams = 0;
    vector<string> deferredArgs;
    for (auto instruction : aSb->instructions) {

        // Function calling starts here ------------------------------- //
        // Quit early if we're calling a function and we're interrupted by some
        // other instructions.
        if (functionCallMode &&
            (instruction->getOp() != PARAM && instruction->getOp() != CALL)) {
            REPORTERR("Function call interrupted by other instructions");
        }
        if (instruction->getOp() == PARAM) {
            if (functionCallMode == false) {
                functionCallMode = true;
                WriteBackAll();
                FlushRegisters();
            }
            numParams++;
            switch (numParams) {
                case 1:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%rdi");
                    break;
                case 2:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%rsi");
                    break;
                case 3:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%rdx");
                    break;
                case 4:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%rcx");
                case 5:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%r8");
                case 6:
                    INSTR2(this->text,
                           movq,
                           memoryOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode()),
                           "%r9");
                    break;
                default:
                    // We have more than 6 parameters, simply push to stack
                    // However, we cannot simply push, since the order would be
                    // reversed, so we defer the pushing.
                    deferredArgs.push_back(
                      memoryOrConstant((void*)instruction->getV1(),
                                       instruction->getV1AddMode()));
            }
        }
        if (instruction->getOp() == CALL) {
            // First do the deferred args
            reverse(deferredArgs.begin(), deferredArgs.end());
            for (auto fragment : deferredArgs) {
                INSTR1(this->text, pushq, fragment);
            }

            // Do any writebacks.
            if (functionCallMode == false) {
                WriteBackAll();
                FlushRegisters();
            }

            // Finally, call
            string* fName;
            if (instruction->getV2AddMode() != STRING ||
                (fName = (string*)instruction->getV2()) == nullptr) {
                REPORTERR("Incorrect name in function invocation");
            }

            INSTR1(this->text, callq, *fName);

            functionCallMode = false;
            deferredArgs.clear();
            numParams = 0;

            // Now, the result is in RAX. We need to move it to the designated
            // memory location.

            STEntry* tempSte;
            if (instruction->getV1AddMode() != REGISTER ||
                (tempSte = (STEntry*)instruction->getV1()) == nullptr) {
                REPORTERR("Incorrect return temporary supplied");
            }

            tempSte->setDirty(1);
            INSTR2(this->text, movq, "%rax", FROMRBP(tempSte->offset));
        }
        // Function calling ends here --------------------------------- //

        // Function returns start here -------------------------------- //
        if (instruction->getOp() == RET) {
            // Returning means the end of a simple block.
            WriteBackAll();
            FlushRegisters();
            // First, load the thing to be returned into RAX TODO
            string op = memoryOrConstant((void*)instruction->getV1(),
                                         instruction->getV1AddMode());
            INSTR2(this->text, movq, op, "%rax");
            // Then, jump to the epilog
            INSTR1(this->text, jmp, "epilog" + this->currentFName);
        }
        // Function returns end here ---------------------------------- //

        // Unary ops start here --------------------------------------- //
        if (instruction->getOp() >= 200 && instruction->getOp() < 250) {
            if (instruction->getV1AddMode() != REGISTER) {
                REPORTERR("Tried to write to non memory location");
            }

            UnaryInstructionType iType = unaryInstructionType(instruction);
            if (iType == AB) {
                // This is the most straightforward, A = op B
                // Prepare the result register.
                STEntry* result = (STEntry*)instruction->getV1();
                MaybeGetRegister(result, false);
                result->setDirty(1);
                string op1 = registerOrConstant((void*)result, REGISTER);

                // Prepare the other two operands.
                maybeGetRegisterIfNotConstant((void*)instruction->getV2(),
                                              instruction->getV2AddMode(),
                                              true);
                string op2 = registerOrConstant((void*)instruction->getV2(),
                                                instruction->getV2AddMode());
                INSTR2(this->text, movq, op2, op1);
                UNARYINSTR2(this->text, instruction->getOp(), op1);
            } else { // if (iType == AA)
                // This is A = op A, this saves one mov instruction
                // Prepare the result register.
                STEntry* result = (STEntry*)instruction->getV1();
                MaybeGetRegister(result, false);
                result->setDirty(1);
                string op1 = registerOrConstant((void*)result, REGISTER);
                UNARYINSTR2(this->text, instruction->getOp(), op1);
            }
        }
        // Unary ops end here ----------------------------------------- //

        // Sane arithmetic ops start here (not div/mod) ---------------- //
        if (instruction->getOp() < 30) {
            if (instruction->getV1AddMode() != REGISTER) {
                REPORTERR("Tried to write to non memory location");
            }

            ArithmeticInstructionType iType =
              arithmeticInstructionType(instruction);
            if (iType == ABC || iType == ABB) {
                // This is the most straightforward case. A = B op C
                // Prepare the result register.
                STEntry* result = (STEntry*)instruction->getV1();
                MaybeGetRegister(result, false);
                result->setDirty(1);
                string op1 = registerOrConstant((void*)result, REGISTER);

                // Prepare the other two operands.
                maybeGetRegisterIfNotConstant((void*)instruction->getV2(),
                                              instruction->getV2AddMode(),
                                              true);
                maybeGetRegisterIfNotConstant((void*)instruction->getV3(),
                                              instruction->getV3AddMode(),
                                              true);
                string op2 = registerOrConstant((void*)instruction->getV2(),
                                                instruction->getV2AddMode());
                string op3 = registerOrConstant((void*)instruction->getV3(),
                                                instruction->getV3AddMode());
                INSTR2(this->text, movq, op2, op1);
                ARITHINSTR2(this->text, instruction->getOp(), op3, op1);
            } else if (iType == AAB) {
                // XXXmilindl: Untested because we never seem to generate ops of
                // this kind in the IR.

                // A = A op B, this requires one MOV less
                // Prepare the result, A, and the first operand at once
                STEntry* result = (STEntry*)instruction->getV1();
                MaybeGetRegister(result, true);
                string op1 = registerOrConstant((void*)result, REGISTER);
                result->setDirty(1);

                // Prepare the other operand
                maybeGetRegisterIfNotConstant((void*)instruction->getV3(),
                                              instruction->getV3AddMode(),
                                              true);
                string op3 = registerOrConstant((void*)instruction->getV3(),
                                                instruction->getV3AddMode());
                ARITHINSTR2(this->text, instruction->getOp(), op3, op1);
            } else if (iType == AAA) {
                // XXXmilindl: Untested because we never seem to generate ops of
                // this kind in the IR.

                // A = A op A, this requires one MOV less
                // Prepare the result, A, and the first operand at once
                STEntry* result = (STEntry*)instruction->getV1();
                MaybeGetRegister(result, true);
                string op1 = registerOrConstant((void*)result, REGISTER);
                result->setDirty(1);

                ARITHINSTR2(this->text, instruction->getOp(), op1, op1);
            } else { // if iType == ABA
                // XXXmilindl: IR never seems to generate these also, lucky for
                // me.
                REPORTERR("IR instruction is in ABA format, unimplemented");
            }
        }
        // Sane arithmetic ops end here (not div/mod) ---------------- //

        // Start memory operations
        if (instruction->getOp() == GETADDR) {
            if (instruction->getV1AddMode() != REGISTER) {
                REPORTERR("Tried to write to non memory location");
            }

            if (instruction->getV2AddMode() != REGISTER) {
                REPORTERR("Tried to address a non memory location");
            }

            STEntry* result = (STEntry*)instruction->getV1();
            STEntry* target = (STEntry*)instruction->getV2();
            MaybeGetRegister(result, false);
            result->setDirty(1);
            string op1 = registerOrConstant((void*)result, REGISTER);
            INSTR2(this->text, leaq, FROMRBP(target->offset), op1);
        }
        if (instruction->getOp() == FOLLOWPTR) {
            if (instruction->getV1AddMode() != REGISTER) {
                REPORTERR("Tried to write to non memory location");
            }

            if (instruction->getV2AddMode() != REGISTER) {
                REPORTERR("Tried to address a non memory location");
            }

            STEntry* result = (STEntry*)instruction->getV1();
            STEntry* target = (STEntry*)instruction->getV2();
            MaybeGetRegister(result, false);
            result->setDirty(1);

            maybeGetRegisterIfNotConstant((void*)target, REGISTER, true);
            string op1 = registerOrConstant((void*)result, REGISTER);
            string op2 = registerOrConstant((void*)target, REGISTER);
            INSTR2(this->text, leaq, "(" + op2 + ")", op1);
        }
        if (instruction->getOp() == ADDRASSIGN) {
            if (instruction->getV1AddMode() != REGISTER) {
                REPORTERR("Tried to write to non memory location");
            }

            // Need to write back to prevent memory being overwritten in case it
            // has already been changed.
            WriteBackAll();
            FlushRegisters();

            // Prepare the first operand.
            STEntry* result = (STEntry*)instruction->getV1();
            MaybeGetRegister(result, false);
            result->setDirty(1);
            string op1 = registerOrConstant((void*)result, REGISTER);

            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV2(), instruction->getV2AddMode(), true);
            string op2 = registerOrConstant((void*)instruction->getV2(),
                                            instruction->getV2AddMode());
            INSTR2(this->text, movq, op2, "(" + op1 + ")");
        }
        if (instruction->getOp() == IELEM) {
            if (instruction->getV1AddMode() != REGISTER ||
                instruction->getV2AddMode() != REGISTER) {
                REPORTERR(
                  "Either the source or the base is not a mem location");
            }

            // The IELEM instruction has the form (source, base, offset)

            // All the three operands should be registers for this to work.

            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV1(), instruction->getV2AddMode(), true);
            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV2(), instruction->getV2AddMode(), true);
            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV3(), instruction->getV3AddMode(), true);

            string op1 = registerOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode());
            string op2 = registerOrConstant((void*)instruction->getV2(),
                                            instruction->getV2AddMode());
            string offsetOp = "";

            // op3 might be a number or a register, we need to deal with it very
            // differently.
            if (instruction->getV3AddMode() == CONSTANT_VAL) {
                long o = *(long*)instruction->getV3();
                offsetOp = to_string(o) + "(" + op2 + ")";
            } else if (instruction->getV3AddMode() == REGISTER) {
                string o = registerOrConstant((void*)instruction->getV3(),
                                              instruction->getV3AddMode());
                offsetOp = "(" + op2 + ", " + o + ", 1)";
            } else {
                REPORTERR("Unexpected type of addressing mode of offset");
            }

            INSTR2(this->text, movq, op1, offsetOp);
        }
        if (instruction->getOp() == EELEM) {
            if (instruction->getV1AddMode() != REGISTER ||
                instruction->getV3AddMode() != REGISTER) {
                REPORTERR(
                  "Either the source or the base is not a mem location");
            }

            // This instruction has the form (lvalue, offset, base)

            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV1(), instruction->getV2AddMode(), false);
            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV2(), instruction->getV2AddMode(), true);
            maybeGetRegisterIfNotConstant(
              (void*)instruction->getV3(), instruction->getV3AddMode(), true);

            string op1 = registerOrConstant((void*)instruction->getV1(),
                                            instruction->getV1AddMode());
            string base = registerOrConstant((void*)instruction->getV3(),
                                             instruction->getV3AddMode());
            string offsetOp = "";

            if (instruction->getV2AddMode() == CONSTANT_VAL) {
                long o = *(long*)instruction->getV2();
                offsetOp = to_string(o) + "(" + base + ")";
            } else if (instruction->getV2AddMode() == REGISTER) {
                string o = registerOrConstant((void*)instruction->getV2(),
                                              instruction->getV2AddMode());
                offsetOp = "(" + base + ", " + o + ", 1)";
            } else {
                REPORTERR("Unexpected type of addressing mode of offset");
            }

            INSTR2(this->text, movq, offsetOp, op1);
        }
        // End memory operations

        // Start insane arithmetic ops
        if (instruction->getOp() == DIV_OP || instruction->getOp() == MOD_OP) {
            // Insane instructions require insane sacrifices
            WriteBackAll();
            FlushRegisters();

            STEntry* result = (STEntry*)instruction->getV1();

            ArithmeticInstructionType iType =
              arithmeticInstructionType(instruction);
            if (iType == AAA) {
                if (instruction->getOp() == DIV_OP) {
                    INSTR2(this->text, movq, NUM(1), FROMRBP(result->offset));
                } else {
                    INSTR2(this->text, movq, NUM(0), FROMRBP(result->offset));
                }
            } else { // if (iType == any)
                string b = memoryOrConstant((void*)instruction->getV2(),
                                            instruction->getV2AddMode());
                string c = memoryOrConstant((void*)instruction->getV3(),
                                            instruction->getV3AddMode());
                INSTR2(this->text, movq, b, "%rax");
                INSTR0(this->text, cqto);
                INSTR2(this->text, movq, c, "%rcx");
                INSTR1(this->text, idiv, "%rcx");
                if (instruction->getOp() == DIV_OP) {
                    INSTR2(this->text, movq, "%rax", FROMRBP(result->offset));
                } else {
                    INSTR2(this->text, movq, "%rdx", FROMRBP(result->offset));
                }
            }
        }
        // End insane arithmetic ops
    }
}

string
X86Generator::Generate()
{
    // The basic generation method which calls all other methods.
    IR ir(this->instructionList, globalTable);
    ir.fillStructure();
    this->complexBlocks = ir.complexBlocks;
    // TODO: Global allocation.
    // TODO: Globals should be marked separately so that they can be written
    // back as per requirement.
    return GenerateFunctions();
}

STEntry*
X86Generator::dummyGetRegister(STEntry* old)
{
    static int regn = -1;
    regn = (regn + 1) % 13;

    old->setReg((Register)(regn + 1));
    return this->regDesc.getRegisterSTE((Register)(regn + 1));
}

void
X86Generator::MaybeWriteBack(Register aRegister)
{
    STEntry* ste;
    // Can't writeback nothing or if already written back.
    if ((ste = regDesc.getRegisterSTE(aRegister)) == nullptr ||
        ste->getDirty() == 0) {
        return;
    }

    INSTR2(this->text, movq, STEREG(ste), FROMRBP(ste->offset));
    ste->setDirty(0);
}

void
X86Generator::LoadFromMemory(STEntry* aSte)
{
    if (aSte == nullptr || aSte->getReg() == NONE ||
        aSte != this->regDesc.getRegisterSTE(aSte->getReg())) {
        // Can'load from nothing, can't load into if register is
        // not owned by STE.
        return;
    }

    INSTR2(this->text, movq, FROMRBP(aSte->offset), STEREG(aSte));
    // Freshly loaded data is not dirty.
    aSte->setDirty(0);
}

void
X86Generator::MaybeGetRegister(STEntry* aRegisterFor, bool aLoadImmediately)
{
    if (aRegisterFor->getReg() == NONE) {
        STEntry* oldSymbolForRegister = dummyGetRegister(aRegisterFor);
        assert(aRegisterFor->getReg() != NONE);

        // Write back if needed.
        if (oldSymbolForRegister != nullptr) {
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
X86Generator::FlushRegisters()
{
    for (int r = RAX; r <= R14; r++) {
        STEntry* ste = this->regDesc.getRegisterSTE((Register)r);
        if (ste != nullptr) {
            // We need to clear this up, writeback has been called before.
            assert(ste->getDirty() == 0);
            ste->setReg(NONE);
            this->regDesc.setRegisterSTE((Register)r, nullptr);
        }
    }
}
void
X86Generator::SynchronizeDescriptors(Register aRegister,
                                     STEntry* oldSymbol,
                                     STEntry* newSymbol)
{
    if (oldSymbol != nullptr) {
        assert(oldSymbol->getReg() == aRegister);
        oldSymbol->setReg(NONE);
        oldSymbol->setDirty(0);
    }

    assert(newSymbol->getReg() == aRegister);
    this->regDesc.setRegisterSTE(aRegister, newSymbol);
    newSymbol->setDirty(0);
}

void
X86Generator::WriteBackAll()
{
    // Note: this depends on the enums being sequential.
    for (int r = RAX; r <= R14; r++) {
        MaybeWriteBack((Register)r);
    }
}
