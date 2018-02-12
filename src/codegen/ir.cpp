#include "ir.h"

// IR

IR::IR(vector<Instruction> instr_list, SymbolTable* symtab)
{
    i_list = instr_list;
    rootSymbolTable = symtab;
    /* rootSymbolTable->addEntry(new SymbolTableEntry("a", INT)); */
    /* rootSymbolTable->addEntry(new SymbolTableEntry("b", INT)); */
    /* rootSymbolTable->addEntry(new SymbolTableEntry("c", INT)); */
    cout << rootSymbolTable->table.size() << endl;
    cout << ((SymbolTableEntry*)rootSymbolTable->getEntry("a"))->getLive()
         << endl;
}

void
IR::addGlobalComplex(ComplexBlock* a)
{
    // The global complex block has a single
    // simple block, whose symbol table has global variables

    globalComplexName = a->getLabel();
    complexBlocks[globalComplexName] = a;
}

void
IR::addComplexBlock(ComplexBlock* a)
{
    complexBlocks[a->getLabel()] = a;
}

ComplexBlock*
IR::getComplexBlock(string a)
{
    return complexBlocks[a];
}

int
IR::utilGetNumComplexBlock()
{
    return complexBlocks.size();
}

Register
IR::getRegister(int flag, SymbolTableEntry* current)
{
    SymbolTableEntry* entry;
    int max = -1;
    Register r = (Register)(-1);
    for (int i = RAX; i <= R15; i++) {
        entry = RegDescTable.getRegisterSTE((Register)i);
        if (entry == NULL)
            return (Register)i;
        if (entry->getNextUse() > max && !entry->getUse()) {
            r = (Register)i;
            if (flag)
                entry->setUse(0);
        }
    }
    if (!flag)
        current->setUse(1);
    RegDescTable.setRegisterSTE(r, current);
    return r;
}

void
IR::fillStructure()
{
    vector<int> leaders;
    vector<int> complexBegin;
    vector<int> complexEnd;

    int num = 0;

    int complexCount = 0;
    int simpleCount = 0;

    string tempID;

    ComplexBlock* globalCB = new ComplexBlock(
      "$global", complexCount++); // Define special global block
    SimpleBlock* globalSB = new SimpleBlock(simpleCount++, globalCB);
    simpleBlockList.push_back(globalSB);

    vector<Instruction>::iterator it;

    for (it = i_list.begin(); it != i_list.end(); it++) {
        if (it->getOp() == FUNC_ST) {
            break;
        }

        globalSB->addInstruction(&(*it));
        num = num + 1;
    }

    addGlobalComplex(globalCB);

    int prevJump = 0; // 0 - not a goto  1 - unconditional  2 -- conditional
    SimpleBlock* tempBlock;
    SimpleBlock* sb;
    ComplexBlock* cb;
    bool done = false;

    // cout << "Global stuff done" << endl;
    // cout << utilGetNumComplexBlock() << endl;

    while (it != i_list.end()) { // Go over the list of all complex blocks

        // cout << "Creating complex on OP " << it->getOp() << endl;

        cb = new ComplexBlock(string((char*)it->getV1()), complexCount++);
        // cout << "The label is " << string((char*)it->getV1()) << endl;
        it++;
        sb = new SimpleBlock(simpleCount++, cb);
        simpleBlockList.push_back(sb);

        for (; it != i_list.end(); it++) {
            if (it->getOp() == FUNC_ST) {
                // cout << "reached funcst on OP " << it->getOp() << endl;
                break;
            }

            if (it->getOp() == FUNC_ET) {
                cb->addBlock(sb);
                addComplexBlock(cb);
                // cout << "Added complex with " << cb->length() << "
                // blocks, there are now " << utilGetNumComplexBlock() <<
                // endl;
                cb->utilPrintSummary();
                it++;
                break;
            }

            // This bit of the code sets up a "current basic block"
            // The first line being a leader is already taken care off
            // Need to take care of i) target of jump ii) following a jump
            // Also if function ends

            // i) Target of jump - finish the current block and create a new
            // one and add index to table
            if (it->getOp() == LABEL_ST) {
                tempBlock = new SimpleBlock(simpleCount++, cb);
                sb->setNextBlock(tempBlock);
                cb->addBlock(sb);
                basicBlockMap[string((char*)it->getV1())] = simpleCount - 1;
                // cout << "Hit a jump statement with label " <<
                // string((char*)it->getV1()) << endl;
                sb = tempBlock;
                simpleBlockList.push_back(sb);
                continue;
            }

            // ii) Following a jump
            if (prevJump > 0) {
                prevJump = 0;
                // cout << "Following a jump" << endl;
                tempBlock = new SimpleBlock(simpleCount++, cb);
                sb->setNextBlock(tempBlock);
                cb->addBlock(sb);
                sb = tempBlock;
                simpleBlockList.push_back(sb);
            }

            // Done with the handling case
            if (it->getOp() == GOTO) {
                prevJump = 1;
            }
            if (it->getOp() == GOTOEQ) {
                prevJump = 2;
            }

            sb->addInstruction(&(*it));
        }

        if (it == i_list.end()) {
            // cout << "Done break" << endl;
            break;
        }
    }

    // Change the gotoeq targets to be indices
    vector<SimpleBlock*>::iterator iter;
    vector<Instruction*>::iterator instIter;
    long* c;
    for (iter = simpleBlockList.begin(); iter != simpleBlockList.end();
         iter++) {
        for (instIter = ((*iter)->instructions).begin();
             instIter != ((*iter)->instructions).end();
             instIter++) {
            if (((*instIter)->getOp() == GOTOEQ) ||
                ((*instIter)->getOp() == GOTO)) {
                c = new long;
                *c = basicBlockMap[string((char*)(*instIter)->getV1())];
                (*instIter)->setV1((void*)c);
            }
        }
    }

    // Do nextuse stuff

    vector<SimpleBlock*>::iterator riter;
    vector<Instruction*>::reverse_iterator ri;

    for (riter = simpleBlockList.begin(); riter != simpleBlockList.end();
         riter++) {
        rootSymbolTable->resetNextUseInfo((*riter)->length());
        for (ri = (*riter)->instructions.rbegin();
             ri != (*riter)->instructions.rend();
             ri++) {
            if ((*ri)->getOp() < 100) {
                // This is the case with 3 things
                // Attach info
                (*ri)->setV1Live(
                  ((SymbolTableEntry*)(*ri)->getV1())->getLive());
                (*ri)->setV2Live(
                  ((SymbolTableEntry*)(*ri)->getV2())->getLive());
                (*ri)->setV3Live(
                  ((SymbolTableEntry*)(*ri)->getV3())->getLive());

                (*ri)->setV1NextUse(
                  ((SymbolTableEntry*)(*ri)->getV1())->getNextUse());
                (*ri)->setV2NextUse(
                  ((SymbolTableEntry*)(*ri)->getV2())->getNextUse());
                (*ri)->setV3NextUse(
                  ((SymbolTableEntry*)(*ri)->getV3())->getNextUse());

                // Set info for first
                ((SymbolTableEntry*)(*ri)->getV1())->setLive(false);
                ((SymbolTableEntry*)(*ri)->getV1())->setNextUse(-1);
                (*ri)->setV1Register(
                  getRegister(0, (SymbolTableEntry*)(*ri)->getV1()));
                // Set info for rest
                ((SymbolTableEntry*)(*ri)->getV2())->setLive(true);
                ((SymbolTableEntry*)(*ri)->getV3())->setLive(true);
                ((SymbolTableEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                ((SymbolTableEntry*)(*ri)->getV3())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                (*ri)->setV2Register(
                  getRegister(0, (SymbolTableEntry*)(*ri)->getV2()));
                (*ri)->setV3Register(
                  getRegister(1, (SymbolTableEntry*)(*ri)->getV3()));

            } else if ((*ri)->getOp() == 100) {
                // for gotoeq
                (*ri)->setV2Live(
                  ((SymbolTableEntry*)(*ri)->getV2())->getLive());
                (*ri)->setV3Live(
                  ((SymbolTableEntry*)(*ri)->getV3())->getLive());

                (*ri)->setV2NextUse(
                  ((SymbolTableEntry*)(*ri)->getV2())->getNextUse());
                (*ri)->setV3NextUse(
                  ((SymbolTableEntry*)(*ri)->getV3())->getNextUse());

                // Set info for rest
                ((SymbolTableEntry*)(*ri)->getV2())->setLive(true);
                ((SymbolTableEntry*)(*ri)->getV3())->setLive(true);
                ((SymbolTableEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                ((SymbolTableEntry*)(*ri)->getV3())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                (*ri)->setV2Register(
                  getRegister(0, (SymbolTableEntry*)(*ri)->getV2()));
                (*ri)->setV3Register(
                  getRegister(1, (SymbolTableEntry*)(*ri)->getV3()));

            } else if (((*ri)->getOp() >= 200) && ((*ri)->getOp() < 240)) {
                // for instr with only 2 operators
                // Attach info
                (*ri)->setV1Live(
                  ((SymbolTableEntry*)(*ri)->getV1())->getLive());
                (*ri)->setV2Live(
                  ((SymbolTableEntry*)(*ri)->getV2())->getLive());

                (*ri)->setV1NextUse(
                  ((SymbolTableEntry*)(*ri)->getV1())->getNextUse());
                (*ri)->setV2NextUse(
                  ((SymbolTableEntry*)(*ri)->getV2())->getNextUse());

                // Set info for first
                ((SymbolTableEntry*)(*ri)->getV1())->setLive(false);
                ((SymbolTableEntry*)(*ri)->getV1())->setNextUse(-1);

                // Set info for rest
                ((SymbolTableEntry*)(*ri)->getV2())->setLive(true);
                ((SymbolTableEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);

                (*ri)->setV1Register(
                  getRegister(0, (SymbolTableEntry*)(*ri)->getV1()));
                (*ri)->setV2Register(
                  getRegister(1, (SymbolTableEntry*)(*ri)->getV2()));
            }
        }
    }
}
/*
int main() {
  SymbolTableEntry* ste = new SymbolTableEntry("a", INT);
  vector<Instruction> my_list;

  const char* a1 = "test1";
  const char* a2 = "test2";
  const char* a3 = "test3";
  const char* a4 = "test4";
  const char* a5 = "test5";
  const char* a6 = "test6";
  const char* a7 = "test7";
  const char* a8 = "test8";


  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE,
NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(ASG, ste, NULL,
NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ST, (void*)a1, NULL, NULL, NONE_MODE,
NONE_MODE, NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(ASG,
ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE,
NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(FUNC_ET,
(void*)a2, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ST, (void*)a3, NULL, NULL, NONE_MODE,
NONE_MODE, NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(ASG,
ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(LABEL_ST, (void*)a4, NULL, NULL, NONE_MODE,
NONE_MODE, NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(GOTO,
(void*)a6, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
   my_list.push_back(Instruction(GOTOEQ, (void*)a7, NULL, NULL, NONE_MODE,
NONE_MODE, NONE_MODE, INT, INT, INT)); my_list.push_back(Instruction(ASG,
ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ET, (void*)a5, NULL, NULL, NONE_MODE,
NONE_MODE, NONE_MODE, INT, INT, INT)); IR ir(my_list); ir.fillStructure();
  // cout << ir.utilGetNumComplexBlock() << endl;
  return 0;

}
*/
