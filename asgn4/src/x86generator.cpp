#include "x86generator.h"

X86Generator::X86Generator(ST* aGlobalTable)
  : globalTable(aGlobalTable)
  , currentFName("main") // remember to fix this
{}

string
X86Generator::StackAlloc()
{
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
    // 3. Move parameters from register to stack space.
    string prolog = this->currentFName + ":";
    INSTR1(prolog, pushq, "%rbp");
    INSTR2(prolog, movq, "%rsp", "%rbp");
    INSTR2(prolog, subq, NUM(this->totalAllocatedSpace), "%rsp");
    return prolog;
}

string
X86Generator::Epilog()
{
    string epilog = "";
    INSTR2(epilog, addq, NUM(this->totalAllocatedSpace), "%rsp");
    INSTR1(epilog, popq, "%rbp");
    INSTR0(epilog, retq);
    return epilog;
}
