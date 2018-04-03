#include "helpers.h"

vector<Instruction*> instructionList;
map<string, Instruction*> instr_map;
map<string, string> label_map;

extern void
inferListType(Node* target, Node* source)
{
    for (int i = 0; i < target->children.size(); ++i) {
        target->children[i]->setType(source->children[i]->getType());
    }
}

extern void 
checkListType(vector<Type*> source, Node * target)
{
    if(source.size() != target->children.size())  {
        cout << "Number of variables different from assignments" << endl;
        exit(1);
    }
    for(int i = 0; i < source.size(); ++i ){
        if(!(*(target->children[i]->getType()) == *(source[i]))){
            cout << "Types mismatch : " << target->children[i]->getType()->GetRepresentation() <<
                " and " << source[i]->GetRepresentation()<<endl;
        }
    }
}

extern void* correctPointer(Node * ptr, ST* curr){
    void * arg1;
    if (ptr->matched != "Literal")
        arg1 = (void*)curr->getVar(ptr->tmp);
    else if (ptr->getType()->GetRepresentation() == "int") {
        long* i = new long;
        *i = atol(ptr->tmp.c_str());
        arg1 = (void*)i;
    } else if (ptr->getType()->GetRepresentation() == "bool") {
        bool* i = new bool;
        *i = ptr->tmp == "true"; // checking true or not
        arg1 = (void*)i;
    }
    return arg1;
}

extern vector<Instruction*>
generateInstructionsAssignment(Node* target, Node* source, ST* curr)
{
    target = fixNodeForExpression(target, curr);
    source = fixNodeForExpression(source, curr);
    vector<Instruction*> i_list;
    Instruction* instr;
    for (int i = 0; i < target->children.size(); ++i) {
        void* arg1 = correctPointer(target->children[i],curr);
        void* arg2 = correctPointer(source->children[i],curr);
        instr = new Instruction(ASG,
                                arg1,
                                arg2,
                                target->children[i]->addrMode,
                                source->children[i]->addrMode,
                                target->children[i]->getType(),
                                source->children[i]->getType());
        i_list.push_back(instr);
    }
    return i_list;
}

extern vector<Type*>
createParamList(Node* list)
{
    vector<Type*> paramTypes; // parameter type list
    if (list->children.size() == 0) {
        return paramTypes;
    }
    Type *def, *ntype;
    int mode = 1; // checks if the passed types are valid or not
    def = list->children[list->count - 1]
            ->getType(); // default paramter in the right to left pass
    ntype =
      new BasicType("NOTYPE"); // works, but never used, check before removing
    for (int i = list->count - 1; i >= 0; i--) {
        if (list->children[i]->count > 1)
            mode = 0; // TODO : error condition
        if (mode)
            paramTypes.push_back(list->children[i]->getType());
        else {
            if (list->children[i]->count > 1) {
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

extern void
printST(ST* root)
{
    static int i = 0;
    cout << "Entering scope : " << ++i << endl;
    cout << string(root->depth * 8, ' ') << "Variables in this scope: " << endl;
    map<string, STEntry*>::iterator it;
    for (it = root->table.begin(); it != root->table.end(); it++) {
        cout << string(root->depth * 8, ' ') << (it->second)->name
             << " of type " << (it->second)->type->GetRepresentation() << endl;
    }

    cout << string(root->depth, ' ') << "Calling recursively: " << endl;
    vector<ST*>::iterator it1;
    for (it1 = root->children.begin(); it1 != root->children.end(); it1++) {
        printST(*it1);
    }
}

extern void
populateST(Node* declNameList, Node* TypeName, ST* curr, bool constant)
{
    vector<string>::iterator it;
    for (int i = 0; i < declNameList->children.size(); ++i) {
        cout << "normal call : " << endl;
        cout << declNameList->children[i]->children[0]->matched << " : "
             << TypeName->type << endl;
        cout << "Loc : " << global_loc->col1 << endl;
        curr->addEntry(declNameList->children[i]->children[0]->matched,
                       TypeName->type,
                       constant);
    }
}

extern void
populateST(Node* declNameList, Node* TypeName, ST* curr)
{
    populateST(declNameList, TypeName, curr, 0);
}

extern void
populateSTInfer(Node* declNameList, ST* curr)
{
    vector<string>::iterator it;
    for (int i = 0; i < declNameList->children.size(); ++i) {
        cout << "infer : " ; 
        cout << declNameList->children[i]->children[0]->matched << " : "
             << declNameList->children[i]->getType() << endl;
        curr->addEntry(declNameList->children[i]->children[0]->matched,
                       declNameList->children[i]->getType(), false);
    }
}

extern vector<string>
getNameList(Node* list)
{
    vector<string> names;
    for (int i = 0; i < list->children.size(); i++)
        names.push_back(list->children[i]->content);
    return names;
}

extern vector<Type*>
repeatType(Node* TypeName, int count)
{
    vector<Type*> repeats;
    for (int i = 0; i < count; ++i)
        repeats.push_back(TypeName->getType());
    return repeats;
}

extern vector<string>
getNames(Node* list)
{
    vector<string> nameList;
    for (int i = 0; i < list->children.size(); ++i) {
        if (list->children[i]->count > 1) {
            for (int j = 0; j < list->children[i]->str_child.size(); ++j)
                nameList.push_back(list->children[i]->str_child[j]);
        } else {
            string s1 = "empty";
            nameList.push_back(s1);
        }
    }
    return nameList;
}

extern vector<Type*>
getTypes(Node* list)
{
    vector<Type*> typeList;
    for (int i = 0; i < list->children.size(); ++i) {
        if (list->children[i]->count > 1) {
            for (int j = 0; j < list->children[i]->type_child.size(); ++j)
                typeList.push_back(list->children[i]->type_child[j]);
        } else {
            typeList.push_back(list->children[i]->getType());
        }
    }
    return typeList;
}

extern Node*
fixNodeForExpression(Node* ptr, ST* curr)
{
    if (ptr->matched == "Name") {
        if (curr->getVar(ptr->content) != NULL)
            ptr->setType(curr->getVar(ptr->content)->type);
        else
            ptr->setType(new BasicType("NOTYPE"));
        ptr->addrMode = REGISTER;
    } else if (ptr->matched == "Literal") {
        ptr->addrMode = CONSTANT_VAL;
    } else if (ptr->matched == "Expression") {
        // TODO: implement this @Prannay
    }
    return ptr;
}

extern vector<Instruction*>
generateInstructionReadArray(Node* source, Node* n1, Node* n2, ST* curr)
{
    n1 = fixNodeForExpression(n1, curr);
    n2 = fixNodeForExpression(n2, curr);
    return source->instr_list;
}

extern void
generateCall(Node* source, Node* fn, vector<Node*> args, ST* curr)
{
    if (fn->matched != "Name") {
        cout << "Cannot deal with anything but the simplest of functions."
             << endl;
        exit(1);
    }

    if ((curr->checkEntryFunc(fn->content))) {
        cout << "Cannot deal with function not in function table yet" << endl;
        exit(1);
    }

    // This function call has no arguments, so just call and store.
    vector<Instruction*> pre_i_list;
    vector<Instruction*> i_list;
    for (auto n : args) {
        n = fixNodeForExpression(n, curr);
        if (n->matched == "Literal") {
            void* p;
            if (n->getType()->GetRepresentation() == "int") {
                long* i = new long;
                *i = atol(n->tmp.c_str());
                p = i;
            } else if (n->getType()->GetRepresentation() == "bool") {
                int* i = new int;
                *i = "true" == n->tmp;
                p = i;
            } else {
                cout << "Literal other than bool or int" << endl;
                exit(1);
            }
            i_list.push_back(
              new Instruction(PARAM, p, CONSTANT_VAL, n->getType()));
        } else if (n->matched == "Name") {
            STEntry* s;
            if (curr->checkEntry(n->content)) {
                cout << "Cannot find Name" << endl;
                exit(1);
            } else {
                s = curr->getVar(n->content);
            }

            i_list.push_back(
              new Instruction(PARAM, (void*)s, REGISTER, n->getType()));
        } else {
            // matched value is something complex, so we need a pre-list.
            STEntry* s;
            if (curr->checkEntry(n->tmp)) {
                cout << "Cannot find Temp" << endl;
                exit(1);
            } else {
                s = curr->getVar(n->tmp);
            }
            pre_i_list = mergeInstructions(pre_i_list, n->instr_list);
            i_list.push_back(
              new Instruction(PARAM, (void*)s, REGISTER, n->getType()));
        }
    }
    string st = "temp";
    string str = st + to_string(clock());
    curr->addEntry(str, ((FuncType*)source->getType())->GetReturnType(), false);
    STEntry* arg3;
    if (!(arg3 = curr->getVar(str))) {
        cout << "STE creation failed" << endl;
        exit(1);
    }

    Instruction* instr;
    // TODOmilindl: Change codegen to switch it around as well, since it is more
    // uniform this way, to have it with the STE before the function name.
    instr = new Instruction(CALL,
                            arg3,
                            (char*)fn->content.c_str(),
                            REGISTER,
                            CONSTANT_VAL,
                            fn->getType(),
                            new BasicType(fn->content));
    i_list.push_back(instr);

    source->instr_list = mergeInstructions(pre_i_list, i_list);
    source->tmp = getTemp(source);
    source->addrMode = REGISTER;
    source->setType(arg3->getType());
}

extern vector<Instruction*>
generateInstructionBIN(OpCode op, Node* n1, Node* n2, ST* curr)
{
    n1 = fixNodeForExpression(n1, curr);
    n2 = fixNodeForExpression(n2, curr);
    void *arg1, *arg2;
    if (n1->matched != "Literal")
        arg1 = (void*)curr->getVar(n1->tmp);
    else if (n1->getType()->GetRepresentation() == "int") {
        long* i = new long;
        *i = atol(n1->tmp.c_str());
        arg1 = (void*)i;
    } else if (n1->getType()->GetRepresentation() == "bool") {
        bool* i = new bool;
        *i = n1->tmp == "true"; // checking true or not
        arg1 = (void*)i;
    }
    if (n2->matched != "Literal") {
        arg2 = curr->getVar(n2->tmp);
    } else if (n2->getType()->GetRepresentation() == "int") {
        long* i = new long;
        *i = atol(n2->tmp.c_str());
        arg2 = (void*)i;
    } else if (n2->getType()->GetRepresentation() == "bool") {
        bool* i = new bool;
        *i = n2->tmp == "true"; // checking true or not
        arg2 = (void*)i;
    }
    string st = "temp";
    string str = st + to_string(clock());
    curr->addEntry(str, n1->getType(), false);
    STEntry* arg3;
    if (!(arg3 = curr->getVar(str))) {
        cout << "STE creation failed" << endl;
        exit(1);
    }
    if (!((*n1->getType()) == (*n2->getType()))) {
        cout << "Error : types mismatch"
             << " ";
        cout << n1->getType()->GetRepresentation() << " ";
        cout << n2->getType()->GetRepresentation() << endl;
    }
    Instruction* instr;
    instr = new Instruction(op,
                            arg3,
                            arg1,
                            arg2,
                            REGISTER,
                            n1->addrMode,
                            n2->addrMode,
                            n1->getType(),
                            n2->getType(),
                            n1->getType());
    vector<Instruction*> i_list;
    i_list = mergeInstructions(i_list, n1->instr_list);
    i_list = mergeInstructions(i_list, n2->instr_list);
    i_list.push_back(instr);
    i_list[0]->printInstruction();
    cout << "asdfasd" << endl;
    cout << i_list.size();
    return i_list;
}

extern Instruction*
generateGotoInstruction(Node* n1, string label, ST* curr, bool cond = true)
{
    STEntry* arg1 = curr->getVar(n1->tmp);
    if (arg1 == NULL) {
        string s = "label" + to_string(clock());
        n1->tmp = s;
        curr->addEntry(n1->tmp, new BasicType("GOTO"), false);
        arg1 = curr->getVar(n1->tmp);
    }
    char* branch = new char;
    size_t len = label.copy(branch, label.length());
    branch[len] = '\0';
    int* i = new int;
    *i = 1;
    Instruction* instr;
    OpCode op;
    if (cond)
        op = GOTOEQ;
    else
        op = GOTONEQ;
    instr = new Instruction(GOTOEQ,
                            (void*)branch,
                            (void*)arg1,
                            (void*)i,
                            CONSTANT_VAL,
                            REGISTER,
                            CONSTANT_VAL,
                            new BasicType(label),
                            n1->getType(),
                            new BasicType("int"));
    return instr;
}

extern Instruction*
generateGotoInstruction(Node* n1, ST* curr)
{
    STEntry* arg1 = curr->getVar(n1->tmp);
    if (arg1 == NULL) {
        curr->addEntry(n1->tmp, new BasicType("NOTYPE"), false);
        arg1 = curr->getVar(n1->tmp);
    }
    string s = "label";
    s = s + to_string(clock());
    char* branch = new char;
    size_t len = s.copy(branch, s.length());
    branch[len] = '\0';
    int* i = new int;
    *i = 1;
    Instruction* instr;
    instr = new Instruction(GOTOEQ,
                            (void*)branch,
                            (void*)arg1,
                            (void*)i,
                            CONSTANT_VAL,
                            REGISTER,
                            CONSTANT_VAL,
                            new BasicType(s),
                            n1->getType(),
                            new BasicType("int"));
    return instr;
}

extern Instruction*
generateUnconditionalGoto(string label, ST* curr)
{
    string s = label;
    char* branch = new char;
    size_t len = s.copy(branch, s.length());
    branch[len] = '\0';
    cout << (void*)(new BasicType(s)) << endl;
    Instruction* instr;
    instr = new Instruction(GOTO_OP, branch, CONSTANT_VAL, new BasicType(s));
    return instr;
}
extern Instruction*
generateUnconditionalGoto(ST* curr)
{
    string s = "label";
    s = s + to_string(clock());
    char* branch = new char;
    size_t len = s.copy(branch, s.length());
    branch[len] = '\0';
    cout << (void*)(new BasicType(s)) << endl;
    Instruction* instr;
    instr = new Instruction(GOTO_OP, branch, CONSTANT_VAL, new BasicType(s));
    return instr;
}

extern vector<Instruction*>
mergeInstructions(vector<Instruction*> first, vector<Instruction*> second)
{
    for (int i = 0; i < second.size(); ++i)
        first.push_back(second[i]);
    return first;
}

extern void
pushInstructionList(vector<Instruction*> instr_list)
{
    for (int i = 0; i < instr_list.size(); ++i)
        pushInstruction(instr_list[i]);
}

extern void
pushInstruction(Instruction* instr)
{
    instructionList.push_back(instr);
}

extern string
getTemp(Node* ptr)
{
    string s;
    // XXXmilindl: This is either a symbol table entry, not a char*
    // I've rewritten it here, but I am not sure of it.
    if (ptr->instr_list.size() == 0) {
        cout << "Instruction list size is 0, cannot have temp variables"
             << endl;
        exit(1);
    }

    if (ptr->instr_list[ptr->instr_list.size() - 1]->getV1AddMode() !=
        REGISTER) {
        cout << "Addressing mode is not REGISTER, cannot have temp variables"
             << endl;
        exit(1);
    }
    STEntry* e =
      (STEntry*)(ptr->instr_list[ptr->instr_list.size() - 1]->getV1());
    return e->name;
}

extern Instruction*
generateUnaryInstruction(OpCode op, Node* source, ST* curr)
{
    string st = "temp";
    string str = st + to_string(clock());
    curr->addEntry(str, source->getType(), false);
    void* target = curr->getVar(str);
    void* src = correctPointer(source,curr);
    Instruction* instr = new Instruction(op,
                                         target,
                                         src,
                                         REGISTER,
                                         source->addrMode,
                                         source->getType(),
                                         source->getType());
    return instr;
}

extern Instruction*
generateLabelInstruction(string s)
{
    char* branch = new char;
    size_t len = s.copy(branch, s.length());
    branch[len] = '\0';
    return new Instruction(LABEL_ST, branch, CONSTANT_VAL, new BasicType(s));
}

extern void
genInstructionBinWrapper(OpCode op,
                         Node* source,
                         Node* first,
                         Node* second,
                         ST* curr)
{
    source->instr_list = generateInstructionBIN(op, first, second, curr);
    source->tmp = getTemp(source);
    source->addrMode = REGISTER;
    source->setType(first->getType());
}

extern bool
isRValueMode(ST* aST)
{
    return aST->rValueMode;
}

extern void
setRValueMode(bool aRValueMode, ST* aST)
{
    aST->rValueMode = aRValueMode;
}

extern void
setScopeReturnType(Type* aReturnType, ST* aST)
{
    aST->scopeReturnType = aReturnType;
}

extern Type*
getScopeReturnType(ST* aST)
{
    if (aST->scopeReturnType == nullptr && aST->parent != nullptr) {
        return getScopeReturnType(aST->parent);
    }
    if (aST->scopeReturnType == nullptr) {
        cout << "Cannot find return type for function" << endl;
        exit(1);
    }
    return aST->scopeReturnType;
}

void
generateFunctionEnder(Node* source, Node* retVal, ST* curr, OpCode op)
{
    if (retVal->count == 0) {
        long* i = new long;
        *i = 0;
        source->instr_list.push_back(
          new Instruction(op, i, CONSTANT_VAL, new BasicType("int")));
    } else if (retVal->count == 1 && getScopeReturnType(curr) == nullptr) {
        cout << "Trying to return something when return type is void" << endl;
        exit(1);
    } else if (retVal->count == 1 &&
               retVal->children[0]->matched == "Literal") {
        if (retVal->children[0]->getType()->GetRepresentation() == "int") {
            long* i = new long;
            *i = atol(retVal->children[0]->content.c_str());
            if (*(new BasicType("int")) != *(getScopeReturnType(curr))) {
                cout << "Return type mismatch" << endl;
                exit(1);
            }
            source->instr_list.push_back(
              new Instruction(op, i, CONSTANT_VAL, new BasicType("int")));
        } else if (retVal->children[0]->getType()->GetRepresentation() ==
                   "bool") {
            long* i = new long;
            *i = retVal->children[0]->content == "true";
            if (*(new BasicType("bool")) != *(getScopeReturnType(curr))) {
                cout << "Return type mismatch" << endl;
                exit(1);
            }
            source->instr_list.push_back(
              new Instruction(op, i, CONSTANT_VAL, new BasicType("bool")));
        }
    } else if (retVal->count == 1 && retVal->children[0]->matched == "Name") {
        STEntry* s;
        if (curr->checkEntry(retVal->children[0]->tmp)) {
            cout << "Can't find variable to return" << endl;
            exit(1);
        }
        s = curr->getVar(retVal->children[0]->tmp);
        if (*(s->getType()) != *(getScopeReturnType(curr))) {
            cout << "Return type mismatch" << endl;
            exit(1);
        }
        source->instr_list.push_back(
          new Instruction(op, s, REGISTER, getScopeReturnType(curr)));
    } else if (retVal->count == 1 &&
               retVal->children[0]->matched == "Expression") {
        string tmp = getTemp(retVal->children[0]);
        STEntry* s;
        if (curr->checkEntry(tmp)) {
            cout << "Can't find variable to return" << endl;
            exit(1);
        }
        s = curr->getVar(tmp);
        if (*(s->getType()) != *(getScopeReturnType(curr))) {
            cout << "Return type mismatch" << endl;
            exit(1);
        }
        source->instr_list =
          mergeInstructions(source->instr_list, retVal->instr_list);
        source->instr_list.push_back(
          new Instruction(op, s, REGISTER, getScopeReturnType(curr)));
    } else {
        cout << "Can return only one thing" << endl;
        exit(1);
    }
}

extern void
generateReturn(Node* source, Node* retVal, ST* curr)
{
    generateFunctionEnder(source, retVal, curr, RET);
}
extern void
generateYield(Node* source, Node* retVal, ST* curr)
{
    generateFunctionEnder(source, retVal, curr, YLD);
}
