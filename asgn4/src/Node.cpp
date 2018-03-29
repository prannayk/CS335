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
    type = new BasicType("NOTYPE");
}

Node::Node(string aMatched, Type* aType, int aCount)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(false)
{
    type = new BasicType("NOTYPE");
}

Node::Node(string aMatched, Type* aType, int aCount, bool aFlag)
  : matched(aMatched)
  , type(aType)
  , children()
  , count(aCount)
  , flag(aFlag)
{
    type = new BasicType("NOTYPE");
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

STEntry::STEntry(string aName, string aType) {
  name = aName;
  type = aType;
}

 ST::ST(int aDepth, ST* aParent) {
   depth = aDepth;
   parent = aParent;
 }
 
 void
 ST::addEntry(string aName, string aType) {
   STEntry* t = new STEntry(aName, aType);
   entries.push_back(t);
 }
 
 void
 ST::addChild(ST* aChild) {
   children.push_back(aChild);
 }
