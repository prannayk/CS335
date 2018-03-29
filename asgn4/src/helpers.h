#pragma once
#include <vector>
#include <iostream>
#include "Node.h"
#include <string>

using namespace std;

struct myLoc {
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};

extern myLoc *global_loc;

extern void inferListType(Node* target, Node* source);

extern void printST(ST* root);
extern void populateST(Node* declNameList, Node* TypeName, ST* curr);
extern void populateST(Node* declNameList, Node* TypeName, ST* curr, bool constant);
