#pragma once
#include <vector>
#include <iostream>
#include "Node.h"
#include "Type.h"
#include <algorithm>
using namespace std;

struct myLoc {
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};

extern myLoc *global_loc;

extern void inferListType(Node* target, Node* source);
extern vector<Type*> createParamList(Node * list);
