#pragma once

#include <iostream>
#include <string.h>
#include <vector>
#include <ostream>
#include <sstream>
#include <iomanip>
#include "Type.h"
#include "enums.h"

using namespace std;


class Node
{
  public:
    string matched;
    string content;
    Type *type;
    AddressingMode addrMode;
    string tmp; // temp variable for value stored in expression eval
    vector<Node*> children;
    vector<string> str_child; // to handle struct type
    vector<Type*> type_child; // to handle types of decl in structs
    int count; // number of args or elements in list
    bool flag; // variadic function marked
    Node(string aMatched, Type* aType, int aCount, bool aFlag);
    Node(string aMatched, Type* aType, int aCount);
    Node(string aMatched, Type* aType);
    Node* Add(Node* aNode);
    Node* Add(string str);
    void Print();
    void PrintJS();
    void incrementCount(Node * nNode); // add a Node, make a list
    void setType(Type *aType){ type = aType; }
    Type* getType() { return this->type; }

};

// symbol table entry data

class STEntry
{
  public:
    string name;
    Type* type;
    bool constant;

    STEntry(string aName, Type* aType);
    STEntry(string aName, Type* aType, bool aConstant);

};

class ST {
   public:
     int depth;
     vector<STEntry*> entries;
     vector<ST*> children;
     ST* parent;
     // prefix method?
 
     ST(int aDepth, ST* aParent);
     void addEntry(string aName, Type* aType, bool aConstant);
     void addChild(ST* aChild);
     STEntry* getVar(string a);

};
