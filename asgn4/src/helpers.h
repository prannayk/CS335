#pragma once
#include <vector>
#include <iostream>
#include "Node.h"
#include <ctime>
#include "Type.h"
#include <algorithm>
#include <string>
#include "enums.h"

using namespace std;

struct myLoc {
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};

extern vector<Instruction*> instructionList;

extern myLoc *global_loc;

extern void inferListType(Node* target, Node* source);
extern vector<Type*> createParamList(Node * list);

extern void printST(ST* root);
extern void populateST(Node* declNameList, Node* TypeName, ST* curr);
extern void populateST(Node* declNameList, Node* TypeName, ST* curr, bool constant);
extern vector<string> getNames(Node * list);
extern vector<Type*> getTypes(Node * list);
extern vector<string> getNameList(Node * list);
extern vector<Type*> repeatType(Node * TypeName, int count);
extern vector<Instruction*> generateInstructionBIN(OpCode op, Node * n1, Node * n2, ST* curr); 
extern Node* fixNodeForExpression(Node *ptr, ST* curr);
extern void pushInstruction(Instruction* instr);
extern void pushInstructionList(vector<Instruction*> instr_list);
extern vector<Instruction*> mergeInstructions(vector<Instruction*>, vector<Instruction*>);
extern string getTemp(Node *);
extern vector<Instruction*> generateInstructionsAssignment(Node * target, Node * source, ST* curr);
extern Instruction* generateGotoInstruction(Node *n1, ST* curr);
extern Instruction* generateUnconditionalGoto(ST* curr);
extern Instruction* generateLabelInstruction(string s);
extern void genInstructionBinWrapper(OpCode op, Node * source, Node * first, Node* second, ST* curr);
extern Instruction* generateUnaryInstruction(OpCode, Node*, ST*);
extern void setRValueMode(bool, ST* aST);
extern bool isRValueMode(ST* aST);
