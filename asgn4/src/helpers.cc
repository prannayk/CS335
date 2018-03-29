#include "helpers.h"

extern void 
inferListType(Node * target, Node * source){
    for(int i = 0; i< target->children.size() ; ++i){
        target->children[i]->setType(source->children[i]->getType());
        cout<<"Inferred Type : "<<target->children[i]->getType()<<endl;
    }
}

extern void printST(ST* root) {
  
  cout << string(root->depth * 8, ' ') << "Variables in this scope: " << endl;
  vector<STEntry*>::iterator it;
  for (it = root->entries.begin(); it != root->entries.end(); it++) {
    cout << string(root->depth * 8, ' ') <<  (*it)->name << " of type " << (*it)->type->GetRepresentation() << endl;
  }
  
  cout << string(root->depth, ' ') << "Calling recursively: " << endl;
  vector<ST*>::iterator it1;
  for (it1 = root->children.begin(); it1 != root->children.end(); it1++) {
    printST(*it1); 
  }

}

extern void populateST(Node* declNameList, Node* TypeName, ST* curr, bool constant) {
  vector<string>::iterator it;
  for (int i = 0; i < declNameList->children.size(); ++i) {
    cout<<declNameList->children[i]->children[0]->matched << " : " << TypeName->type<<endl;
    curr->addEntry(declNameList->children[i]->children[0]->matched, TypeName->type, constant);
  }
}

extern void populateST(Node* declNameList, Node* TypeName, ST* curr) {
  populateST(declNameList, TypeName, curr, 0);
}
