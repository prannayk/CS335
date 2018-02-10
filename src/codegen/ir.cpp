#include "ir.h"

// IR

IR::IR(vector<Instruction> instr_list)
{
    i_list = instr_list;
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
IR::utilGetNumComplexBlock() {
    return complexBlocks.size();
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

        cb =
          new ComplexBlock(string((char*)it->getV1()), complexCount++);
        // cout << "The label is " << string((char*)it->getV1()) << endl;
        it++;
        sb = new SimpleBlock(simpleCount++, cb);

        for (; it != i_list.end(); it++) {
            if (it->getOp() == FUNC_ST) {
                // cout << "reached funcst on OP " << it->getOp() << endl;
                break;
            }

            if (it->getOp() == FUNC_ET) {
                cb->addBlock(sb);
                addComplexBlock(cb);
                // cout << "Added complex with " << cb->length() << " blocks, there are now " << utilGetNumComplexBlock() << endl;
                // cb -> utilPrintSummary();
                it++;
                break;
            }

            // This bit of the code sets up a "current basic block"
            // The first line being a leader is already taken care off
            // Need to take care of i) target of jump ii) following a jump
            // Also if function ends

            // i) Target of jump - finish the current block and create a new one
            // and add index to table
            if (it->getOp() == LABEL_ST) {
                tempBlock = new SimpleBlock(simpleCount++, cb);
                sb->setNextBlock(tempBlock);
                cb->addBlock(sb);
                basicBlockMap[string((char*)it->getV1())] = simpleCount - 1;
                // cout << "Hit a jump statement with label " << string((char*)it->getV1()) << endl;
                sb = tempBlock;
            }

            // ii) Following a jump
            if (prevJump > 0) {
                prevJump = 0;
                // cout << "Following a jump" << endl;
                tempBlock = new SimpleBlock(simpleCount++, cb);
                sb->setNextBlock(tempBlock);
                cb->addBlock(sb);
                sb = tempBlock;
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
}

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


  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ST, (void*)a1, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ET, (void*)a2, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ST, (void*)a3, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(LABEL_ST, (void*)a4, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(GOTO, (void*)a6, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
   my_list.push_back(Instruction(GOTOEQ, (void*)a7, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(ASG, ste, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  my_list.push_back(Instruction(FUNC_ET, (void*)a5, NULL, NULL, NONE_MODE, NONE_MODE, NONE_MODE, INT, INT, INT));
  IR ir(my_list);
  ir.fillStructure();
  // cout << ir.utilGetNumComplexBlock() << endl;
  return 0;

}
