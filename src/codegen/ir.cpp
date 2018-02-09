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

void
IR::fillStructure() {

  vector<int> leaders;
  vector<int> complexBegin;
  vector<int> complexEnd;

  int num = 0;

  int complexCount = 0;
  int simpleCount = 0;

  string tempID;

  ComplexBlock* globalCB = new ComplexBlock("$global", complexCount++); // Define special global block
  SimpleBlock* globalSB = new SimpleBlock(simpleCount++, globalCB);
  
  vector<Instruction>::iterator it;

  for (it = i_list.begin(); it!= i_list.end(); it++) {
    if (it -> getOp() == FUNC_ST) {
      break;
    }

    globalSB -> addInstruction(&(*it));
    num = num + 1;

  }

  addGlobalComplex(globalCB);

  int prevJump = 0;   // 0 - not a goto  1 - unconditional  2 -- conditional
  SymbolTable* tempBlock;
  bool done = false;

  while (1) { // Go over the list of all complex blocks
    
    ComplexBlock* cb = new ComplexBlock(string((char *)(it->getV1())), complexCount++);
    SimpleBlock* sb = new SimpleBlock(simpleCount++, cb);

    for (; it != i_list.end(); it++) {
      if (it -> getOp() == FUNC_ST) {
        break;
      }

      // This bit of the code sets up a "current basic block"
      // The first line being a leader is already taken care off
      // Need to take care of i) target of jump ii) following a jump
      // Also if function ends

      //i) Target of jump - finish the current block and create a new one and add index to table
      if (it -> getOp() == LABEL) {
        SimpleBlock* tempBlock = new SimpleBlock(simpleCount++, cb);
        sb -> setNextBlock(tempBlock);
        cb->addBlock(sb);
        basicBlockMap[string((char *)(it -> getV1()))] = simpleCount - 1;
        sb = tempBlock;
        continue;
      }

      //ii) Following a jump
      if (prevJump) {
        prevJump = 0;
        SimpleBlock* tempBlock = new SimpleBlock(simpleCount++, cb);
        sb -> setNextBlock(tempBlock);
        cb->addBlock(sb);
        sb = tempBlock;
        continue;
      }

      // Done with the handling case
      if (it -> getOp() == GOTO) {
        prevJump = 1;
      }
      if (it -> getOp() == GOTOEQ) {
        prevJump = 2;
      }

      sb -> addInstruction(&(*it));
    }

    if (it == i_list.end()) {
      break;
    }
  }

}
