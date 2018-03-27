#include "helpers.h"

extern void 
inferListType(Node * target, Node * source){
    for(int i = 0; i< target->children.size() ; ++i){
        target->children[i]->setType(source->children[i]->getType());
        cout<<"Inferred Type : "<<target->children[i]->getType()<<endl;
    }
}
