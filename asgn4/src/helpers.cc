#include "helpers.h"

extern void 
inferListType(Node * target, Node * source){
    for(int i = 0; i< target->children.size() ; ++i){
        target->children[i]->setType(source->children[i]->getType());
        cout<<"Inferred Type : "<<target->children[i]->getType()<<endl;
    }
}

extern vector<Type*>
createParamList(Node * list){
    vector<Type*> paramTypes; // parameter type list
    Type* def, *ntype; int mode = 1; // checks if the passed types are valid or not
    def = list->children[0]->children[list->count-1]->getType(); // default paramter in the right to left pass
    ntype = new BasicType("NOTYPE"); // works, but never used, check before removing
    for (int i=list->count - 1; i>= 0; i--){
        if (list->children[0]->children[i]->count > 1)  mode = 0; // TODO : error condition
        if(mode)
            paramTypes.push_back(list->children[0]->children[i]->getType());
        else{
            if(list->children[0]->children[i]->count > 1){
                if (def != list->children[0]->children[i]->getType()) 
                    def = list->children[0]->children[i]->getType();
                paramTypes.push_back(list->children[0]->children[i]->getType());
            } else {
                paramTypes.push_back(def);
            }
        }
    }
    reverse(paramTypes.begin(), paramTypes.end());
    return paramTypes;
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
