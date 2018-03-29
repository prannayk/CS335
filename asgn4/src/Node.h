#pragma once

#include <iostream>
#include <string.h>
#include <vector>
#include <ostream>
#include <sstream>
#include <iomanip>
#include "Type.h"

using namespace std;


class Node
{
  public:
    string matched;
    string content;
    Type *type;
    vector<Node*> children;
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
    string type;

    STEntry(string aName, string aType);

};

class ST {
   public:
     int depth;
     vector<STEntry*> entries;
     vector<ST*> children;
     ST* parent;
     // prefix method?
 
     ST(int aDepth, ST* aParent);
     void addEntry(string aName, string aType);
     void addChild(ST* aChild);

};
