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

    bool dirty;
    bool valid;
    
    Register reg;

    bool live;
    int nextUse;
    int active;


    string getName() const { return name; }

    bool getDirty() const { return dirty; }
    bool getValid() const { return valid; }

    Register getReg() const { return reg; }

    Type* getType() const { return type; }

    bool getLive() const { return live; }
    int getNextUse() const { return nextUse; }
		int getUse() const { return active; }


		void setName(string a) { name = a; }

		void setDirty(bool a) { dirty = a; }
    void setValid(bool a) { valid = a; }

    void setReg(Register a) { reg = a; }

    void setType(Type* a) { type = a; }

    void setLive(bool a) { live = a; }
    void setNextUse(int a) {nextUse = a; }

		void setUse(int a) { active = a; } 


    STEntry(string aName, Type* aType);
    STEntry(string aName, Type* aType, bool aConstant);

};

class ST {
   public:
    
     static map<string, StructDefinitionType*> structDefs;

     int depth;

     map<string, STEntry*> table;
     map<string, string> structs;

     vector<ST*> children;

     ST* parent;
     ST* global;
     // prefix method?
 
     ST(int aDepth, ST* aParent);
     void addEntry(string aName, Type* aType, bool aConstant);
     void addStructEntry(string aName, string structName);
     void addChild(ST* aChild);
     STEntry* getVar(string a);
     STEntry* getStructVar(string aName, string memberName);
     
     bool checkEntry(string a);
     void resetNextUseInfo(int a);

    ST* getParentScope() const { return parent; }
    ST* getGlobalScope() const { return global; }

    // Setters
    void setParentScope(ST* a) { parent = a; }
		void setGlobalScope(ST* a) { global = a; }

};
