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
