#pragma once
#include <vector>
#include <iostream>
#include "Node.h"
#include "Type.h"
#include <algorithm>
#include <string>

using namespace std;

struct myLoc {
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};

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
