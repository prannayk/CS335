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
{
}

Node::Node(string aMatched, Type* aType, int aCount)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(false)
{
}

Node::Node(string aMatched, Type* aType, int aCount, bool aFlag)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(aFlag)
{
}


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
Node::incrementCount(Node *nNode){
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



STEntry::STEntry(string aName, Type* aType) {
  name = aName;
  type = aType;
}

STEntry::STEntry(string aName, Type* aType, bool aConstant) {
  name = aName;
  type = aType;
  constant = aConstant;
}

map<string, StructDefinitionType*> ST::structDefs;

 ST::ST(int aDepth, ST* aParent) {
   depth = aDepth;
   parent = aParent;
 }
 
 void
 ST::addEntry(string aName, Type* aType, bool aConstant) {
   STEntry* t = new STEntry(aName, aType, aConstant);
   table[aName] = t;
 }

void
ST::addStructEntry(string aName, string structName) {
  StructDefinitionType* t = ST::structDefs[structName];
  map<string, Type*>::iterator iter;
  string temp;
  for (iter = (t->fields).begin(); iter != (t->fields).end(); iter++ ) {
    temp = aName + t->randomSuffix + iter->first;
    addEntry(temp, iter->second, 0);
  }
  structs[aName] = structName;

}
 
 void
 ST::addChild(ST* aChild) {
   children.push_back(aChild);
 }

bool
ST::checkEntry(string a) {
  if (getVar(a) == NULL) {
    return true;
  }
  return false;
}

void
ST::resetNextUseInfo(int a) {
  map<string, STEntry*>::iterator iter;
  for (iter = table.begin(); iter != table.end(); iter++) {
    (*(iter->second)).setLive(false);
    (*(iter->second)).setNextUse(a);
  }
}

STEntry*
ST::getStructVar(string aName, string memberName) {
  StructDefinitionType* t = ST::structDefs[structs[aName]];
  string temp = aName + t->randomSuffix + memberName;
  return getVar(temp);
}

STEntry*
ST::getVar(string a) {

  if (table.count(a)) {
    return table[a];
  }

  if (depth == 0) {
    return nullptr;
  }
  return parent->getVar(a);
}
