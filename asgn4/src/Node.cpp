#include "Node.h"

Node*
Node::Add(Node* aNode)
{
    this->children.push_back(aNode);
    return this;
}

Node*
Node::Add(string str)
{
    this->children.push_back(new Node(str, new BasicType("NoType")));
    return this;
}

Node::Node(string aMatched, Type* aType)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(1)
  , flag(false)
{}

Node::Node(string aMatched, Type* aType, int aCount)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(false)
{}

Node::Node(string aMatched, Type* aType, int aCount, bool aFlag)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(aFlag)
{}

void
Node::Print()
{
    stringstream ss;
    ss << quoted(this->matched);
    cerr << "{ \"name\" : " << ss.str() << ", \"children\" : [";
    for (int i = 0; i < this->children.size(); ++i) {
        this->children[i]->Print();
    }
    cerr << "]}," << endl;
}

void
Node::PrintJS()
{
    cerr << "const data = [";
    this->Print();
    cerr << "][0];";
}

void
Node::incrementCount(Node* nNode)
{
    this->children.push_back(nNode);
    count++;
}

// int
// main()
// {
//     Node* parentNode = new Node("parent", new BasicType("NOTYPE"));
//     parentNode->Add("terminalChild")
//       ->Add((new Node("nonTerminalChild",
//       new BasicType("NOTYPE")))->Add("SecondTerminalChild"))
//       ->Print();
//     return 0;
// }
//

STEntry::STEntry(string aName, Type* aType)
{
    name = aName;
    type = aType;
}

STEntry::STEntry(string aName, Type* aType, bool aConstant)
{
    name = aName;
    type = aType;
    constant = aConstant;
}

map<string, StructDefinitionType*> ST::structDefs;
map<string, FuncType*> ST::funcDefs;

ST::ST(int aDepth, ST* aParent)
{
    depth = aDepth;
    parent = aParent;
}

void
ST::addEntry(string aName, Type* aType, bool aConstant)
{
    STEntry* t = new STEntry(aName, aType, aConstant);
    table[aName] = t;
}

void
ST::addStructEntry(string aName, string structName)
{
    StructDefinitionType* t = ST::structDefs[structName];
    map<string, Type*>::iterator iter;
    string temp;
    for (iter = (t->fields).begin(); iter != (t->fields).end(); iter++) {
        temp = aName + t->randomSuffix + iter->first;
        addEntry(temp, iter->second, 0);
    }
    structs[aName] = structName;
}

void
ST::addChild(ST* aChild)
{
    children.push_back(aChild);
}

bool
ST::checkEntry(string a)
{
    if (getVar(a) == NULL) {
        return true;
    }
    return false;
}

void
ST::resetNextUseInfo(int a)
{
    map<string, STEntry*>::iterator iter;
    for (iter = table.begin(); iter != table.end(); iter++) {
        (*(iter->second)).setLive(false);
        (*(iter->second)).setNextUse(a);
    }
}

STEntry*
ST::getStructVar(string aName, string memberName)
{
    StructDefinitionType* t = ST::structDefs[structs[aName]];
    string temp = aName + t->randomSuffix + memberName;
    return getVar(temp);
}

STEntry*
ST::getVar(string a)
{

    if (table.count(a)) {
        return table[a];
    }

    if (depth == 0) {
        return nullptr;
    }
    return parent->getVar(a);
}

void
addToSymbolTable();

Instruction::Instruction(OpCode aOp,
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
                         int aV3num)
{
    op = aOp;
    numOps = 3;
    v1 = aV1;
    v2 = aV2;
    v3 = aV3;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v3AddMode = aV3AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v3Type = aV3Type;
    v1num = aV1num;
    v2num = aV2num;
    v3num = aV3num;
}

Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         void* aV3,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         AddressingMode aV3AddMode,
                         Type* aV1Type,
                         Type* aV2Type,
                         Type* aV3Type)
{
    op = aOp;
    numOps = 3;
    v1 = aV1;
    v2 = aV2;
    v3 = aV3;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v3AddMode = aV3AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v3Type = aV3Type;
}

Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         Type* aV1Type,
                         Type* aV2Type)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
}
Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         Type* aV1Type,
                         Type* aV2Type,
                         int aV1num,
                         int aV2num)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v1num = aV1num;
    v2num = aV2num;
}
Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         void* aV2,
                         AddressingMode aV1AddMode,
                         AddressingMode aV2AddMode,
                         Type* aV1Type,
                         Type* aV2Type,
                         int aV2num)
{
    op = aOp;
    numOps = 2;
    v1 = aV1;
    v2 = aV2;
    v1AddMode = aV1AddMode;
    v2AddMode = aV2AddMode;
    v1Type = aV1Type;
    v2Type = aV2Type;
    v2num = aV2num;
}

Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         AddressingMode aV1AddMode,
                         Type* aV1Type)
{
    op = aOp;
    numOps = 1;
    v1 = aV1;
    v1AddMode = aV1AddMode;
    v1Type = aV1Type;
}

Instruction::Instruction(OpCode aOp,
                         void* aV1,
                         AddressingMode aV1AddMode,
                         Type* aV1Type,
                         int numV1)
{
    op = aOp;
    numOps = 1;
    v1 = aV1;
    v1AddMode = aV1AddMode;
    v1Type = aV1Type;
    v1num = numV1;
}

Instruction::Instruction(OpCode aOp)
{
    numOps = 0;
    op = aOp;
    v1AddMode = NONE_MODE;
    v1Type = new BasicType("NOTYPE");
}

void
Instruction::printInstruction()
{
    // cout << op << " " << v1AddMode << " " << v1Type->GetRepresentation();
    string op1 =
      v1AddMode == REGISTER ? ((STEntry*)v1)->getName() : to_string(*(long*)v1);
    string op2 =
      v2AddMode == REGISTER ? ((STEntry*)v2)->getName() : to_string(*(long*)v2);
    string op3 =
      v3AddMode == REGISTER ? ((STEntry*)v3)->getName() : to_string(*(long*)v3);
    cout << op << " " << op1 << "(" << v1Type->GetRepresentation() << ") "
         << op2 << "(" << v2Type->GetRepresentation() << ") " << op3 << "("
         << v3Type->GetRepresentation() << ")" << endl;
}

bool
ST::checkEntryFunc(string a)
{
    if (getFunc(a) == NULL) {
        return true;
    }
    return false;
}

FuncType*
ST::getFunc(string a)
{

    if (funcDefs.count(a)) {
        return funcDefs[a];
    }
    return nullptr;
}
