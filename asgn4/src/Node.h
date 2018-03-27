#pragma once

#include <iostream>
#include <string.h>
#include <vector>
#include <ostream>
#include <sstream>
#include <iomanip>

using namespace std;

enum Type
{
    INT_TYPE = 1,
    STR_TYPE,
    BYTE_TYPE,
    HEX_TYPE,
    BOOL_TYPE,
    NOTYPE,
};

class Node
{
  public:
    string matched;
    string content;
    Type type;
    vector<Node*> children;
    int count; // number of args or elements in list
    bool flag; // variadic function marked
    Node(string aMatched, Type aType, int aCount, bool aFlag);
    Node(string aMatched, Type aType, int aCount);
    Node(string aMatched, Type aType);
    Node* Add(Node* aNode);
    Node* Add(string str);
    void Print();
    void PrintJS();
    void incrementCount(Node * nNode); // add a Node, make a list
    void setType(Type aType){ type = aType; }
    Type getType() { return this->type; }
};
