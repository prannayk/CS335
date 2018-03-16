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
    this->children.push_back(new Node(str, NOTYPE));
    return this;
}

Node::Node(string aMatched, Type aType)
  : matched(aMatched)
  , type(aType)
  , children()
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
    cerr << "];";
}
// int
// main()
// {
//     Node* parentNode = new Node("parent", NOTYPE);
//     parentNode->Add("terminalChild")
//       ->Add((new Node("nonTerminalChild",
//       NOTYPE))->Add("SecondTerminalChild"))
//       ->Print();
//     return 0;
// }
