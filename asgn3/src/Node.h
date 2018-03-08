#pragma once

#include <iostream>
#include <string.h>
#include <vector>
#include <ostream>

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
    Node(string aMatched, Type aType);
    Node* Add(Node* aNode);
    Node* Add(string str);
    void Print();
};
