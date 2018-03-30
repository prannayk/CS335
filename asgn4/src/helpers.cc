#include "helpers.h"

vector<Instruction*> instructionList;

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
    def = list->children[list->count-1]->getType(); // default paramter in the right to left pass
    ntype = new BasicType("NOTYPE"); // works, but never used, check before removing
    for (int i=list->count - 1; i>= 0; i--){
        if (list->children[i]->count > 1)  mode = 0; // TODO : error condition
        if(mode)
            paramTypes.push_back(list->children[i]->getType());
        else{
            if(list->children[i]->count > 1){
                if (def != list->children[i]->getType()) 
                    def = list->children[i]->getType();
                paramTypes.push_back(list->children[i]->getType());
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

extern vector<string> getNameList(Node * list){
   vector<string> names;
   for(int i=0; i< list->children.size(); i++)
       names.push_back(list->children[i]->content);
   return names;
}

extern vector<Type*> repeatType(Node * TypeName, int count){
    vector<Type*> repeats;
    for(int i=0; i<count; ++i)  repeats.push_back(TypeName->getType());
    return repeats;
}

extern vector<string> getNames(Node * list){
    vector<string> nameList;
    for(int i=0;  i < list->children.size() ; ++i ){
        if(list->children[i]->count > 1){
            for(int j = 0; j < list->children[i]->str_child.size(); ++j)
                nameList.push_back(list->children[i]->str_child[j]);
        } else {
            string s1 = "empty";
            nameList.push_back(s1);
        }
    }
    return nameList;
}

extern vector<Type*> getTypes(Node * list){
    vector<Type*> typeList;
    for(int i=0; i < list->children.size() ; ++i ){
        if(list->children[i]->count > 1){
            for(int j = 0; j < list->children[i]->type_child.size(); ++j)
                typeList.push_back(list->children[i]->type_child[j]);
        } else {
            typeList.push_back(list->children[i]->getType());
        }
    }
    return typeList;
}

extern string generateInstruction(OpCode op, Node * n1, Node * n2, ST *curr){
    STEntry * arg1 = curr->getVar(n1->tmp);
    STEntry * arg2 = curr->getVar(n2->tmp);
    string str = "tmp"; // TODO : replace with random string
    STEntry * arg3 = curr->getVar(str);
    if (n1->getType() != n2->getType()) cout << "Error : types mismatch" << endl;
    Instruction * instr = new Instruction(op, arg3, arg2, arg1, REGISTER, n1->addrMode, n2->addrMode, n1->getType(), n2->getType(), n1->getType() );
    instructionList.push_back(instr); // TODO: replace with real list of instruction 
    return str;
}
