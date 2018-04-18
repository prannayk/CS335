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



class Instruction
{
  private:
    OpCode op;

    const void* v1;
    const void* v2;
    const void* v3;

    AddressingMode v1AddMode;
    AddressingMode v2AddMode;
    AddressingMode v3AddMode;

    Type* v1Type;
    Type* v2Type;
    Type* v3Type;

    int v1num, v2num, v3num;
    
    
    Register v1reg, v2reg, v3reg;
    
    int numOps;

    bool v1Live;
    bool v2Live;
    bool v3Live;
    int v1NextUse;
    int v2NextUse;
    int v3NextUse;

  public:
    // Constructors
    Instruction(OpCode aOp, void* aV1, void* aV2, void* aV3,
                AddressingMode aV1AddMode, AddressingMode aV2AddMode,
                AddressingMode aV3AddMode, Type* aV1Type, Type* aV2Type,
                Type* aV3Type);
    Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         void* aV3,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         AddressingMode aV3AddMode,
                         Type* aV1Type,
                         Type* aV2Type,
                         Type* aV3Type, 
                         int aV1num, 
                         int aV2num, 
                         int aV3num);

    Instruction(OpCode aOp, void* aV1, void* aV2, AddressingMode aV1AddMode,
                AddressingMode aV2AddMode, Type* aV1Type, Type* aV2Type);
    Instruction(OpCode aOp, void* aV1, void* aV2, AddressingMode aV1AddMode,
                AddressingMode aV2AddMode, Type* aV1Type, Type* aV2Type, int aV2Num); // for function declaration only

    Instruction(OpCode aOp,
                void* aV1,
                void* aV2,
                AddressingMode aV1AddMode,
                AddressingMode aV2AddMode,
                Type* aV1Type,
                Type* aV2Type, 
                int aV1num, int aV2num);
    Instruction(OpCode aOp, void* aV1, AddressingMode aV1AddMode, Type* aV1Type);
    Instruction(OpCode aOp, void* aV1, AddressingMode aV1AddMode, Type* aV1Type, int numV1);
    Instruction(OpCode aOp);
    // Getters
    OpCode getOp() { return op; }

    const void* getV1() { return v1; }
    const void* getV2() { return v2; }
    const void* getV3() { return v3; }

    AddressingMode getV1AddMode() { return v1AddMode; }
    AddressingMode getV2AddMode() { return v2AddMode; }
    AddressingMode getV3AddMode() { return v3AddMode; }

    Type* getV1Type() { return v1Type; }
    Type* getV2Type() { return v2Type; }
    Type* getV3Type() { return v3Type; }

    int getNumOps() { return numOps; }

    bool getV1Live() {return v1Live; }
    bool getV2Live() {return v2Live; }
    bool getV3Live() {return v3Live; }
    int getV1NextUse() {return v1NextUse; }
    int getV2NextUse() {return v2NextUse; }
    int getV3NextUse() {return v3NextUse; }

    Register getV1Register() { return v1reg; }
    Register getV2Register() { return v2reg; }
    Register getV3Register() { return v3reg; }

    // Setters
    void setOp(OpCode a) { op = a; }

    void setV1(void* a) { v1 = a; }
    void setV2(void* a) { v2 = a; }
    void setV3(void* a) { v3 = a; }

    void setV1AddMode(AddressingMode a) { v1AddMode = a; }
    void setV2AddMode(AddressingMode a) { v2AddMode = a; }
    void setV3AddMode(AddressingMode a) { v3AddMode = a; }

    void setV1Type(Type* a) { v1Type = a; }
    void setV2Type(Type* a) { v2Type = a; }
    void setV3Type(Type* a) { v3Type = a; }

    void setV1Live(bool a) { v1Live = a; }
    void setV2Live(bool a) { v2Live = a; }
    void setV3Live(bool a) { v3Live = a; }
    void setV1NextUse(int a) {v1NextUse = a; }
    void setV2NextUse(int a) {v2NextUse = a; }
    void setV3NextUse(int a) {v3NextUse = a; }

    void setV1Register(Register a) { v1reg = a; }
    void setV2Register(Register a) { v2reg = a; }
    void setV3Register(Register a) { v3reg = a; }

    // Print Instruction 
    void printInstruction();
};

class Node
{
  public:
    string matched;
    string content;
    Type *type;
    vector<Instruction*> instr_list;
    AddressingMode addrMode;
    vector<Instruction*> patchInstruction;
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
    void printInstructionList();

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

    bool arrayType; 

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
     static map<string, FuncType*> funcDefs;
     static vector<STEntry*> paramEntryStack;

     static bool paramPush;
     static bool structPush;
     static string structName;
     static string funcName;

     bool rValueMode = false;
     Type* scopeReturnType = nullptr;

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
     static FuncType* getFunc(string a);
     STEntry* getStructVar(string aName, string memberName);
     
     bool checkEntry(string a);
     static bool checkEntryFunc(string a);
     static bool checkEntryStruct(string a);
     void resetNextUseInfo(int a);

    ST* getParentScope() const { return parent; }
    ST* getGlobalScope() const { return global; }

    // Setters
    void setParentScope(ST* a) { parent = a; }
		void setGlobalScope(ST* a) { global = a; }

};
