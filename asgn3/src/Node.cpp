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
    cout << this->matched << " : [";
    for (int i = 0; i < this->children.size(); ++i) {
        this->children[i]->Print();
        cout << "," << endl;
    }
    cout << "]" << endl;
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
