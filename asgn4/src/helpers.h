#pragma once
#include "Node.h"
#include "Type.h"
#include "enums.h"
#include <algorithm>
#include <ctime>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

struct myLoc
{
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};
extern char* filename;
extern vector<Instruction*> instructionList;

extern myLoc* global_loc;
extern map<string, Instruction*> instr_map;
extern map<string, string> label_map;
extern void
inferListType(Node* target, Node* source);
extern vector<Type*>
createParamList(Node* list);

extern void
printST(ST* root);
extern void
populateST(Node* declNameList, Node* TypeName, ST* curr);
extern void
populateST(Node* declNameList, Node* TypeName, ST* curr, bool constant);
extern vector<string>
getNames(Node* list);
extern vector<Type*>
getTypes(Node* list);
extern vector<string>
getNameList(Node* list);
extern vector<Type*>
repeatType(Node* TypeName, int count);
extern vector<Instruction*>
generateInstructionBIN(OpCode op, Node* n1, Node* n2, ST* curr);
extern Node*
fixNodeForExpression(Node* ptr, ST* curr);
extern void
pushInstruction(Instruction* instr);
extern void
pushInstructionList(vector<Instruction*> instr_list);
extern vector<Instruction*>
mergeInstructions(vector<Instruction*>, vector<Instruction*>);
extern string
getTemp(Node*);
extern vector<Instruction*>
generateInstructionsAssignment(Node* target, Node* source, ST* curr);
extern Instruction*
generateGotoInstruction(Node* n1, ST* curr);
extern Instruction*
generateGotoInstruction(Node*, string, ST*, bool);
extern Instruction*
generateUnconditionalGoto(ST* curr);
extern Instruction*
generateUnconditionalGoto(string, ST*);
extern Instruction*
generateLabelInstruction(string s);
extern void
genInstructionBinWrapper(OpCode op,
                         Node* source,
                         Node* first,
                         Node* second,
                         ST* curr);
extern Instruction*
generateUnaryInstruction(OpCode, Node*, ST*);
extern void
populateSTInfer(Node* declNameList, ST* curr);
extern void
populateSTTypeList(vector<string> names, vector<Type*> types, ST* curr);
extern void
setRValueMode(bool, ST* aST);
extern bool
isRValueMode(ST* aST);
extern vector<Instruction*>
generateInstructionReadArray(Node*, Node*, Node*, ST*);
extern void 
checkListType(vector<Type*> source, Node * target);
extern void
generateCall(Node* source, Node* fn, vector<Node*> args, ST*);
extern void setScopeReturnType(Type* aReturnType, ST* aST);
extern Type* getScopeReturnType(ST* aST);
extern void generateReturn(Node* source, Node* retVal, ST* curr);
extern void generateYield(Node* source, Node* retVal, ST* curr);
extern void* correctPointer(Node * ptr, ST* curr);
extern string*
getCharFromString(string s);
extern vector<string> createNameList(Node* list);
extern void syntaxError(string aMessage);
extern void semanticError(string aMessage);
