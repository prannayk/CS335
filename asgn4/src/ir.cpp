#include "ir.h"

// IR

IR::IR(vector<Instruction*> instr_list, ST* symtab)
{
    i_list = instr_list;
    rootST = symtab;
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
IR::getRegister(int flag, STEntry* current)
{
    STEntry* entry;
    int max = -1;
    Register r = (Register)(-1);
    for (int i = RAX; i <= R14; i++) {
        entry = RegDescTable.getRegisterSTE((Register)i);
        if (entry && flag)
            entry->setUse(0);

        if (entry == NULL) {
            r = (Register)i;
            break;
        }

        if (entry->getNextUse() > max && !entry->getUse()) {
            r = (Register)i;
            max = entry->getNextUse();
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

    for (auto it : i_list) {
        if (it->getOp() == FUNC_ST) {
            break;
        }

        globalSB->addInstruction(it);
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
    // TODO: talk with this with abhibhav, I might have unintentinally affected
    // behaviour
    vector<Instruction*>::iterator it;
    it = i_list.begin();
    while (it != i_list.end()) { // Go over the list of all complex blocks

        cb = new ComplexBlock(*(string*)(*it)->getV1(), complexCount++);
        it++;
        sb = new SimpleBlock(simpleCount++, cb);
        simpleBlockList.push_back(sb);

        for (; it != i_list.end(); it++) {
            if ((*it)->getOp() == FUNC_ST) {
                // cout << "reached funcst on OP " << it->getOp() << endl;
                break;
            }

            if ((*it)->getOp() == FUNC_ET) {
                cb->addBlock(sb);
                addComplexBlock(cb);
                // cout << "Added complex with " << cb->length() << "
                // blocks, there are now " << utilGetNumComplexBlock() <<
                // endl;
                it++;
                break;
            }

            // This bit of the code sets up a "current basic block"
            // The first line being a leader is already taken care off
            // Need to take care of i) target of jump ii) following a jump
            // Also if function ends

            // i) Target of jump - finish the current block and create a new
            // one and add index to table
            if ((*it)->getOp() == LABEL_ST) {
                tempBlock = new SimpleBlock(simpleCount++, cb);
                sb->setNextBlock(tempBlock);
                cb->addBlock(sb);
                basicBlockMap[*(string*)(*it)->getV1()] = simpleCount - 1;
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
            if ((*it)->getOp() == GOTO_OP) {
                prevJump = 1;
            }
            if ((*it)->getOp() == GOTOEQ) {
                prevJump = 2;
            }

            sb->addInstruction(*it);
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
                ((*instIter)->getOp() == GOTO_OP)) {
                c = new long;
                *c = basicBlockMap[(*(string*)(*instIter)->getV1())];
                (*instIter)->setV1((void*)c);
            }
        }
    }

    // Do nextuse stuff
    // return; // TODO: Fix with abhibhav, use dummy function right now.
    vector<SimpleBlock*>::iterator riter;
    vector<Instruction*>::reverse_iterator ri;

    for (riter = simpleBlockList.begin(); riter != simpleBlockList.end();
         riter++) {
        rootST->resetNextUseInfo((*riter)->length());
        for (ri = (*riter)->instructions.rbegin();
             ri != (*riter)->instructions.rend();
             ri++) {
            if ((*ri)->getOp() < 100) {
                // This is the case with 3 things
                // Attach info
                (*ri)->setV1Live(((STEntry*)(*ri)->getV1())->getLive());
                (*ri)->setV2Live(((STEntry*)(*ri)->getV2())->getLive());
                (*ri)->setV3Live(((STEntry*)(*ri)->getV3())->getLive());

                (*ri)->setV1NextUse(((STEntry*)(*ri)->getV1())->getNextUse());
                (*ri)->setV2NextUse(((STEntry*)(*ri)->getV2())->getNextUse());
                (*ri)->setV3NextUse(((STEntry*)(*ri)->getV3())->getNextUse());

                // Set info for first
                ((STEntry*)(*ri)->getV1())->setLive(false);
                ((STEntry*)(*ri)->getV1())->setNextUse(MAXVECTORSIZE);
                (*ri)->setV1Register(getRegister(0, (STEntry*)(*ri)->getV1()));
                // Set info for rest
                ((STEntry*)(*ri)->getV2())->setLive(true);
                ((STEntry*)(*ri)->getV3())->setLive(true);
                ((STEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                ((STEntry*)(*ri)->getV3())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                (*ri)->setV2Register(getRegister(0, (STEntry*)(*ri)->getV2()));
                (*ri)->setV3Register(getRegister(1, (STEntry*)(*ri)->getV3()));

            } else if ((*ri)->getOp() == 100) {
                // for gotoeq
                (*ri)->setV2Live(((STEntry*)(*ri)->getV2())->getLive());
                (*ri)->setV3Live(((STEntry*)(*ri)->getV3())->getLive());

                (*ri)->setV2NextUse(((STEntry*)(*ri)->getV2())->getNextUse());
                (*ri)->setV3NextUse(((STEntry*)(*ri)->getV3())->getNextUse());

                // Set info for rest
                ((STEntry*)(*ri)->getV2())->setLive(true);
                ((STEntry*)(*ri)->getV3())->setLive(true);
                ((STEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                ((STEntry*)(*ri)->getV3())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);
                (*ri)->setV2Register(getRegister(0, (STEntry*)(*ri)->getV2()));
                (*ri)->setV3Register(getRegister(1, (STEntry*)(*ri)->getV3()));

            } else if (((*ri)->getOp() >= 200) && ((*ri)->getOp() < 240)) {
                // for instr with only 2 operators
                // Attach info
                (*ri)->setV1Live(((STEntry*)(*ri)->getV1())->getLive());
                (*ri)->setV2Live(((STEntry*)(*ri)->getV2())->getLive());

                (*ri)->setV1NextUse(((STEntry*)(*ri)->getV1())->getNextUse());
                (*ri)->setV2NextUse(((STEntry*)(*ri)->getV2())->getNextUse());

                // Set info for first
                ((STEntry*)(*ri)->getV1())->setLive(false);
                ((STEntry*)(*ri)->getV1())->setNextUse(MAXVECTORSIZE);

                // Set info for rest
                ((STEntry*)(*ri)->getV2())->setLive(true);
                ((STEntry*)(*ri)->getV2())
                  ->setNextUse(
                    distance(begin((*riter)->instructions), ri.base()) - 1);

                (*ri)->setV1Register(getRegister(0, (STEntry*)(*ri)->getV1()));
                (*ri)->setV2Register(getRegister(1, (STEntry*)(*ri)->getV2()));
            }
        }
    }
}
/*
int main() {
  STEntry* ste = new STEntry("a", INT);
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
