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
    NOTYPE,
};

class Node
{
  public:
    string matched;
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
};
