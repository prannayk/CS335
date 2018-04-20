#include "helpers.h"

vector<Instruction*> instructionList;
map<string, Instruction*> goto_map;
map<string, Instruction*> cont_map;
map<string, Instruction*> break_map;
map<string, string> goto_label_map;
map<string, string> cont_label_map;
map<string, string> break_label_map;
multimap<string, FuncType*> fn_map;
char* filename;

extern void
inferListType(Node* target, Node* source)
{
    for (int i = 0; i < target->children.size(); ++i) {
        target->children[i]->setType(source->children[i]->getType());
    }
}

extern void
checkListType(vector<Type*> source, Node* target)
{
    if (source.size() != target->children.size()) {
        semanticError("Number of variables different from assignments");
        return;
    }
    for (int i = 0; i < source.size(); ++i) {
        if (!(*(target->children[i]->getType()) == *(source[i]))) {
            semanticError("Types mismatch : " +
                          target->children[i]->getType()->GetRepresentation() +
                          +" and " + source[i]->GetRepresentation());
            return;
        }
    }
}

extern void*
correctPointer(string s, ST* curr)
{
    void* arg1;
    if (curr->getVar(s))
        return curr->getVar(s);
    else {
        semanticError("Variable or temporary not found");
    }
}

extern Type*
correctType(string s, ST* curr)
{
    if (curr->getVar(s))
        return curr->getVar(s)->getType();
    else {
        semanticError("Variable or temporary not found");
    }
}

extern Type*
correctType(Node* ptr, ST* curr)
{
    Type* arg1;
    if (ptr->matched != "Literal")
        arg1 = curr->getVar(ptr->tmp)->getType();
    else {
        arg1 = ptr->getType();
    }
    return arg1;
}
extern void*
correctPointer(Node* ptr, ST* curr)
{
    void* arg1;
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

extern void
backPatch(map<string, Instruction*> instr_map, string s)
{
    string* str = new string;
    *str = s;
    while (instr_map.count(s)) {
        instr_map[s]->setV1(str);
        instr_map.erase(s);
    }
}

extern Instruction*
generateEqualityInstruction(Node* target, Node* source, ST* curr, string s)
{
    target = fixNodeForExpression(target, curr);
    source = fixNodeForExpression(source, curr);
    string* str = new string;
    *str = s;
    Instruction* instr;
    void* arg1 = correctPointer(target, curr);
    void* arg2 = correctPointer(source, curr);
    instr = new Instruction(GOTOEQ,
                            str,
                            arg1,
                            arg2,
                            STRING,
                            source->addrMode,
                            target->addrMode,
                            new BasicType("switchstmt"),
                            source->getType(),
                            target->getType());
    return instr;
}

extern vector<Instruction*>
generateInstructionsAssignment(Node* target, Node* source, ST* curr)
{
    target = fixNodeForExpression(target, curr);
    source = fixNodeForExpression(source, curr);
    vector<Instruction*> i_list;
    Instruction* instr;
    for (int i = 0; i < target->children.size(); ++i) {
        void* arg1 = correctPointer(target->children[i], curr);
        void* arg2 = correctPointer(source->children[i], curr);

        if (target->children[i]->matched == "PointerWrite") {
            instr = new Instruction(
              ADDRASSIGN,
              // If this is the case, then the expression must be of the
              // form *x, so this gives us the STE related to "x".
              curr->table[target->children[i]->children[1]->content],
              arg2,
              target->children[i]->addrMode,
              source->children[i]->addrMode,
              target->children[i]->getType(),
              source->children[i]->getType());
        } else {
            instr = new Instruction(ASG,
                                    arg1,
                                    arg2,
                                    target->children[i]->addrMode,
                                    source->children[i]->addrMode,
                                    target->children[i]->getType(),
                                    source->children[i]->getType());
        }
        i_list.push_back(instr);
        if (!target->children[i]->matched.compare("ArrayAccess")) {
            i_list =
              mergeInstructions(i_list, target->children[i]->patchInstruction);
        }
        if (!target->children[i]->matched.compare("StructAccess")) {
            i_list =
              mergeInstructions(i_list, target->children[i]->patchInstruction);
        }
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

extern vector<string>
createNameList(Node* list)
{
    vector<string> names;
    if (list->children.size() == 0) {
        return names;
    }
    for (int i = 0; i < list->count; i++) {
        names.push_back(list->children[i]->content);
    }
    return names;
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
             << " of type " << (it->second)->type->GetRepresentation()
             << " and number " << ((it->second)->type)->GetTypeClass() << endl;
    }

    cout << string(root->depth, ' ') << "Calling reluctantly: " << endl;
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
        if (TypeName->type->GetTypeClass() == 5) { // This is a struct
            curr->addStructEntry(
              declNameList->children[i]->children[0]->matched,
              TypeName->type->GetRepresentation());
        }
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
        /* curr->addEntry(declNameList->children[i]->children[0]->matched, */
        /* declNameList->children[i]->getType(), */
        /* false); */
        cout << "Entry" << declNameList->children[i]->children[0]->matched
             << endl;
    }
}

extern void
populateSTTypeList(vector<string> names, vector<Type*> types, ST* curr)
{
    if (names.size() != types.size()) {
        cout << "Type List and Name List mismatch" << endl;
        exit(1);
    }
    vector<string>::iterator itn;
    vector<Type*>::iterator itt;
    for (itn = names.begin(), itt = types.begin();
         (itn != names.end()) && (itt != types.end());
         itn++, itt++) {
        curr->addEntry(*itn, *itt, false);
        if ((*itt)->GetTypeClass() == 5) {
            curr->structs[*itn] = ((StructType*)(*itt))->structName;
        }
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
        ptr->tmp = ptr->content;
    } else if (ptr->matched == "Literal") {
        ptr->addrMode = CONSTANT_VAL;
    } else if (ptr->matched == "Expression") {
        // TODO: implement this @Prannay
        // TODO : I do not see the problem @Milindl
        // TODO: My bad sorry @Prannay
    } else if (ptr->matched == "PseudoCall") {
        if (curr->getVar(ptr->content) != NULL) {
            ptr->setType(curr->getVar(ptr->content)->type);
        } else {
            ptr->setType(new BasicType("NOTYPE"));
            ptr->addrMode = REGISTER;
        }
    } else {
        // ptr->tmp = ptr->matched;
    }
    return ptr;
}

extern vector<Instruction*>
copyInstruction(vector<Instruction*> i_list, int offset)
{
    vector<Instruction*> new_list;
    for (auto elem : i_list) {
        new_list.push_back(elem);
        if ((offset++) >= i_list.size())
            break;
    }
    return new_list;
}

extern vector<Instruction*>
generateInstructionReadArray(Node* source, ST* curr)
{
    Instruction* instr;
    string temp = "temp" + to_string(number());
    string temp2 = "temp" + to_string(number());
    source->tmp = temp;
    curr->addEntry(source->tmp, new BasicType("int"), false);
    curr->addEntry(temp2, new BasicType("int"), false);
    void* arg1 = correctPointer(source->content, curr);
    if (((STEntry*)arg1)->getType()->GetTypeClass() != 4) {
        semanticError("Invalid operation for non-array type");
    }
    vector<string>::iterator it;
    Type* type = ((ArrayType*)((STEntry*)arg1)->getType())->GetArrayType();
    vector<Instruction*> i_list;
    long* initVal = new long;
    *initVal = 0;
    i_list.push_back(new Instruction(ASG,
                                     correctPointer(temp, curr),
                                     (void*)initVal,
                                     REGISTER,
                                     CONSTANT_VAL,
                                     new BasicType("int"),
                                     new BasicType("int")));
    for (it = source->str_child.begin(); it != source->str_child.end(); ++it) {
        void* arg2 = correctPointer(*it, curr);
        if (arg2 == NULL) {
            semanticError("Incorrect Temp name");
        } else {
            if (!(*curr->getVar(*it)->getType() == *(new BasicType("int")))) {
                semanticError("Can not index array with non integer type");
            } else {
                long* ptr = new long;
                *ptr = type->GetMemSize();
                Instruction* instr = new Instruction(
                  MUL_OPER,
                  correctPointer(temp2, curr), // multiply by size of allocation
                  arg2,
                  ptr,
                  REGISTER,
                  REGISTER,
                  CONSTANT_VAL,
                  new BasicType("int"),
                  new BasicType("int"),
                  new BasicType("int"));
                i_list.push_back(instr);
                instr = new Instruction(
                  ADD_OPER,
                  correctPointer(temp, curr), // add offset to offset temporary
                  correctPointer(temp, curr),
                  correctPointer(temp2, curr),
                  REGISTER,
                  REGISTER,
                  REGISTER,
                  new BasicType("int"),
                  new BasicType("int"),
                  new BasicType("int"));
                i_list.push_back(instr);
                if (type->GetTypeClass() == 4)
                    type = ((ArrayType*)type)->GetArrayType();
                else
                    break;
            }
        }
    }
    i_list.push_back(new Instruction(
      PARAM, correctPointer(temp, curr), REGISTER, new BasicType("int")));
    string* printName = new string;
    *printName = "__print";
    string tempstr = "temp" + to_string(number());
    curr->addEntry(tempstr, new BasicType("int"), false);
    i_list.push_back(new Instruction(CALL,
                                     correctPointer(tempstr, curr),
                                     (void*)printName,
                                     REGISTER,
                                     STRING,
                                     new BasicType("int"),
                                     new BasicType("function_name")));
    Type* currentType = type;
    source->tmp = "temp" + to_string(number());
    type = ((ArrayType*)source->getType())->GetArrayType();
    curr->addEntry(
      source->tmp, ((ArrayType*)source->getType())->GetArrayType(), false);
    instr = new Instruction(
      EELEM,
      correctPointer(source, curr),
      correctPointer(temp, curr),
      arg1,
      REGISTER,
      REGISTER,
      REGISTER,
      type,
      new BasicType("int"),
      new BasicType(
        "int")); // target is the temporary, temp is offset (
                 // multiplied by size of base type), and 3rd input STE
                 // of array (should be translated to base address)
    i_list.push_back(instr);
    source->setType(currentType);
    return i_list;
    /* //TODO : set tmp with temporary variable */
    /* //TODO : create redundant instruction in patchInstruction */
    /* //TODO : convert back patching to multi map */
    /* n1 = fixNodeForExpression(n1, curr); */
    /* n2 = fixNodeForExpression(n2, curr); */
    /* string s = "temp" + to_string(number()); */
    /* string* str = new string; */
    /* *str = s; */
    /* void* arg1 = correctPointer(n1, curr); */
    /* if (arg1 != NULL) { */
    /*    if (((STEntry*)arg1)->getType()->GetTypeClass() != 4) { */
    /*        semanticError("Non-Array Type indexed in operation"); */
    /*    } */
    /* } */
    /* void* arg2 = correctPointer(n2, curr); */
    /* Instruction* instr; */
    /* source->addrMode = REGISTER; */
    /* if (*(n2->getType()) != *(new BasicType("int"))) { */
    /*    semanticError("Can not index array with non integer type"); */
    /* } */
    /* vector<Instruction*> i_list; */
    /* long * num = new long; *num = n2->getType()->GetMemSize(); */
    /* instr = new Instruction(MUL_OPER, arg2, arg2, num, */
    /*                       n2->addrMode, n2->addrMode, REGISTER, */
    /*                       n2->getType(), n2->getType(), new BasicType("int")
     */
    /*                       ); */
    /* i_list.push_back(instr); */
    /* instr = new Instruction(EELEM, */
    /*                        str, */
    /*                        arg1, */
    /*                        arg2, */
    /*                        source->addrMode, */
    /*                        n1->addrMode, */
    /*                        n2->addrMode, */
    /*                        source->getType(), */
    /*                        n1->getType(), */
    /*                        n2->getType()); */
    /* source->tmp = s; */
    /* i_list.push_back(instr); */
    /* return i_list; */
}

extern vector<Instruction*>
generateInstructionWriteArray(Node* source, ST* curr)
{
    Instruction* instr;
    string temp = "temp" + to_string(number());
    string temp2 = "temp" + to_string(number());
    source->tmp = temp;
    curr->addEntry(source->tmp, new BasicType("int"), false);
    curr->addEntry(temp2, new BasicType("int"), false);
    void* arg1 = correctPointer(source->content, curr);
    if (((STEntry*)arg1)->getType()->GetTypeClass() != 4) {
        semanticError("Invalid operation for non-array type");
    }
    vector<string>::iterator it;
    Type* type = ((ArrayType*)(((STEntry*)arg1)->getType()))->GetArrayType();
    vector<Instruction*> i_list;
    long* initVal = new long;
    *initVal = 0;
    i_list.push_back(new Instruction(ASG,
                                     correctPointer(temp, curr),
                                     (void*)initVal,
                                     REGISTER,
                                     CONSTANT_VAL,
                                     new BasicType("int"),
                                     new BasicType("int")));
    for (it = source->str_child.begin(); it != source->str_child.end(); ++it) {
        void* arg2 = correctPointer(*it, curr);
        if (arg2 == NULL) {
            semanticError("Incorrect Temp name");
        } else {
            if (!(*curr->getVar(*it)->getType() == *(new BasicType("int")))) {
                semanticError("Can not index array with non integer type");
            } else {
                long* ptr = new long;
                *ptr = type->GetMemSize();
                Instruction* instr = new Instruction(
                  MUL_OPER,
                  correctPointer(temp2, curr), // multiply by size of allocation
                  arg2,
                  ptr,
                  REGISTER,
                  REGISTER,
                  CONSTANT_VAL,
                  new BasicType("int"),
                  new BasicType("int"),
                  new BasicType("int"));
                i_list.push_back(instr);
                instr = new Instruction(
                  ADD_OPER,
                  correctPointer(temp, curr), // add offset to offset temporary
                  correctPointer(temp, curr),
                  correctPointer(temp2, curr),
                  REGISTER,
                  REGISTER,
                  REGISTER,
                  new BasicType("int"),
                  new BasicType("int"),
                  new BasicType("int"));
                i_list.push_back(instr);
                if (type->GetTypeClass() == 4)
                    type = ((ArrayType*)type)->GetArrayType();
                else
                    break;
            }
        }
    }
    Type* currentType = type;
    source->tmp = "temp" + to_string(number());
    type = ((ArrayType*)source->getType())->GetArrayType();
    curr->addEntry(
      source->tmp, ((ArrayType*)source->getType())->GetArrayType(), false);
    instr = new Instruction(
      IELEM,
      correctPointer(source, curr),
      arg1,
      correctPointer(temp, curr),
      REGISTER,
      REGISTER,
      REGISTER,
      type,
      new BasicType("int"),
      new BasicType(
        "int")); // target is the temporary, temp is offset (
                 // multiplied by size of base type), and 3rd input STE
                 // of array (should be translated to base address)
    i_list.push_back(instr);
    source->setType(currentType);
    return i_list;
}

extern vector<Instruction*>
generateInstructionReadStruct(Node* source,
                              Node* n1,
                              Node* n2,
                              Type* ty,
                              ST* curr)
{
    // TODO : set tmp with temporary variable
    // TODO : create redundant instruction in patchInstruction
    // TODO : convert back patching to multi map

    n1 = fixNodeForExpression(n1, curr);
    // n2 = fixNodeForExpression(n2, curr);
    string s = "temp" + to_string(number());
    string* str = new string;
    *str = s;
    void* arg1 =
      correctPointer(n1->content, curr); // This should be n1->content I think
    if (arg1 != NULL) {
        if (((STEntry*)arg1)->getType()->GetTypeClass() != 5) {
            semanticError("Non-Struct Type indexed in operation");
        }
    }
    Instruction* instr;
    source->addrMode = REGISTER;
    if (*(n2->getType()) != *(new BasicType("int"))) {
        semanticError("Can not index array with non integer type");
    }
    vector<Instruction*> i_list;

    source->tmp = "temp" + to_string(number());
    curr->addEntry(source->tmp, ty, false);
    long* offset = new long;
    *offset = atol(n2->content.c_str());
    instr = new Instruction(
      EELEM,
      correctPointer(source, curr),
      (void*)offset,
      arg1,
      REGISTER,
      CONSTANT_VAL,
      REGISTER,
      ty,
      new BasicType("int"),
      new BasicType(
        "int")); // target is the temporary, temp is offset (
                 // multiplied by size of base type), and 3rd input STE
                 // of array (should be translated to base address)
    i_list.push_back(instr);
    source->setType(ty);
    return i_list;
}

extern vector<Instruction*>
generateInstructionWriteStruct(Node* source,
                               Node* base,
                               Node* addr,
                               Type* ty,
                               ST* curr)
{
    Instruction* instr;
    string temp = "temp" + to_string(number());
    source->tmp = temp;
    curr->addEntry(source->tmp, new BasicType("int"), false);

    void* arg1 =
      correctPointer(base->content, curr); // TODO : add in header new function
    if (((STEntry*)arg1)->getType()->GetTypeClass() != 5) {
        semanticError("Invalid operation for non-struct type");
    }
    Type* type = ((StructType*)source->getType())->GetStructType();
    vector<Instruction*> i_list;

    source->tmp = "temp" + to_string(number());

    curr->addEntry(
      source->tmp, ((StructType*)source->getType())->GetStructType(), false);

    instr = new Instruction(
      IELEM,
      correctPointer(source, curr),
      // XXXmilindl: Abhibhav pls check this
      arg1,
      correctPointer(addr, curr),
      REGISTER,
      REGISTER,
      CONSTANT_VAL,
      ty,
      new BasicType("int"),
      new BasicType(
        "int")); // target is the temporary, arg2 is offset (
                 // multiplied by size of base type), and 3rd input STE
                 // of array (should be translated to base address)
    i_list.push_back(instr);
    source->setType(ty);
    return i_list;
}

extern void
generateCall(Node* source,
             string fname,
             Type* fntype,
             vector<Node*> args,
             ST* curr)
{
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
                long* i = new long;
                *i = "true" == n->tmp;
                p = i;
            } else {
                semanticError("Literal other than bool or int");
                return;
            }
            i_list.push_back(
              new Instruction(PARAM, p, CONSTANT_VAL, n->getType()));
        } else if (n->matched == "Name") {
            STEntry* s;
            if (curr->checkEntry(n->content)) {
                semanticError("Cannot find Name");
                return;
            } else {
                s = curr->getVar(n->content);
            }

            i_list.push_back(
              new Instruction(PARAM, (void*)s, REGISTER, n->getType()));
        } else if (n->matched == "StructAccess") {
            STEntry* s;
            if (curr->checkEntry(n->contentStruct)) {
                semanticError("Cannot find Struct");
                return;
            }
            s = (STEntry*)curr->getVar(n->contentStruct);
            i_list.push_back(
              new Instruction(PARAM, (void*)s, REGISTER, s->getType()));
        } else {
            // matched value is something complex, so we need a pre-list.
            STEntry* s;
            if (curr->checkEntry(n->tmp)) {
                semanticError("Cannot find Temp");
                return;
            } else {
                s = curr->getVar(n->tmp);
            }
            pre_i_list = mergeInstructions(pre_i_list, n->instr_list);
            i_list.push_back(
              new Instruction(PARAM, (void*)s, REGISTER, n->getType()));
        }
    }
    string st = "temp";
    string str = st + to_string(number());
    curr->addEntry(str, source->getType(), false);
    STEntry* arg3;
    if (!(arg3 = curr->getVar(str))) {
        semanticError("STE creation failed");
        return;
    }

    Instruction* instr;
    // TODOmilindl: Change codegen to switch it around as well, since it is more
    // uniform this way, to have it with the STE before the function name.
    string* nm = new string;
    *nm = fname;
    instr = new Instruction(
      CALL, arg3, nm, REGISTER, STRING, fntype, new BasicType(fname));
    i_list.push_back(instr);

    source->instr_list = mergeInstructions(pre_i_list, i_list);
    source->tmp = getTemp(source);
    source->addrMode = REGISTER;
    source->setType(arg3->getType());
}

extern vector<Instruction*>
generateInstructionBIN(OpCode op, Node* n1, Node* n2, ST* curr)
{
    vector<Instruction*> i_list;
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
    string str = st + to_string(number());
    curr->addEntry(str, n1->getType(), false);
    STEntry* arg3;
    if (!(arg3 = curr->getVar(str))) {
        semanticError("STE creation failed");
        return i_list;
    }
    if (!((*n1->getType()) == (*n2->getType()))) {
        semanticError("Error : types mismatch " +
                      n1->getType()->GetRepresentation() + " " +
                      n2->getType()->GetRepresentation());
        return i_list;
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
    i_list = mergeInstructions(i_list, n1->instr_list);
    i_list = mergeInstructions(i_list, n2->instr_list);
    i_list.push_back(instr);
    return i_list;
}

extern string*
getCharFromString(string s)
{
    string* str = new string;
    *str = s;
    return str;
}

extern Instruction*
generateGotoInstruction(Node* n1, string label, ST* curr, bool cond)
{
    STEntry* arg1 = curr->getVar(n1->tmp);
    if (arg1 == NULL) {
        string s = "label" + to_string(number());
        n1->tmp = s;
        curr->addEntry(n1->tmp, new BasicType("GOTO"), false);
        arg1 = curr->getVar(n1->tmp);
    }
    string* branch = getCharFromString(label);
    long* i = new long;
    *i = 1;
    Instruction* instr;
    OpCode op;
    if (cond)
        op = GOTOEQ;
    else
        op = GOTONEQ;
    instr = new Instruction(op,
                            (void*)branch,
                            (void*)arg1,
                            (void*)i,
                            STRING,
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
    s = s + to_string(number());
    string* branch = getCharFromString(s);
    long* i = new long;
    *i = 1;
    Instruction* instr;
    instr = new Instruction(GOTOEQ,
                            (void*)branch,
                            (void*)arg1,
                            (void*)i,
                            STRING,
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
    string* branch = getCharFromString(label);
    Instruction* instr;
    instr = new Instruction(GOTO_OP, branch, STRING, new BasicType(s));
    return instr;
}
extern Instruction*
generateUnconditionalGoto(ST* curr)
{
    string s = "label";
    s = s + to_string(number());
    string* branch = getCharFromString(s);
    Instruction* instr;
    instr = new Instruction(GOTO_OP, branch, STRING, new BasicType(s));
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
    source = fixNodeForExpression(source, curr);
    string st = "temp";
    string str = st + to_string(number());
    curr->addEntry(str, source->getType(), false);
    void* target = curr->getVar(str);
    void* src = correctPointer(source, curr);
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
    string* str = new string;
    *str = s;
    return new Instruction(LABEL_ST, str, STRING, new BasicType(s));
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
        semanticError("Trying to return something when return type is void");
        return;
    } else if (retVal->count == 1 &&
               retVal->children[0]->matched == "Literal") {
        if (retVal->children[0]->getType()->GetRepresentation() == "int") {
            long* i = new long;
            *i = atol(retVal->children[0]->content.c_str());
            if (*(new BasicType("int")) != *(getScopeReturnType(curr))) {
                semanticError("Return type mismatch");
                return;
            }
            source->instr_list.push_back(
              new Instruction(op, i, CONSTANT_VAL, new BasicType("int")));
        } else if (retVal->children[0]->getType()->GetRepresentation() ==
                   "bool") {
            long* i = new long;
            *i = retVal->children[0]->content == "true";
            if (*(new BasicType("bool")) != *(getScopeReturnType(curr))) {
                semanticError("Return type mismatch");
                return;
            }
            source->instr_list.push_back(
              new Instruction(op, i, CONSTANT_VAL, new BasicType("bool")));
        }
    } else if (retVal->count == 1 && retVal->children[0]->matched == "Name") {
        STEntry* s;
        if (curr->checkEntry(retVal->children[0]->tmp)) {
            semanticError("Can't find variable to return");
            return;
        }
        s = curr->getVar(retVal->children[0]->tmp);
        if (*(s->getType()) != *(getScopeReturnType(curr))) {
            semanticError("Return type mismatch");
            return;
        }
        source->instr_list.push_back(
          new Instruction(op, s, REGISTER, getScopeReturnType(curr)));
    } else if (retVal->count == 1 && (retVal->matched == "Expression")) {
        string tmp = getTemp(retVal->children[0]);
        STEntry* s;
        if (curr->checkEntry(tmp)) {
            semanticError("Can't find variable to return");
            return;
        }
        s = curr->getVar(tmp);
        if (*(s->getType()) != *(getScopeReturnType(curr))) {
            semanticError("Return type mismatch");
            return;
        }
        source->instr_list =
          mergeInstructions(source->instr_list, retVal->instr_list);
        source->instr_list.push_back(
          new Instruction(op, s, REGISTER, getScopeReturnType(curr)));
    } else {
        semanticError("Can return only one thing");
        return;
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

void
reportError(string aMessage, string precu)
{
    string sp;
    ifstream f;
    f.open(filename, ios::in);
    int current_line = 0;
    while (getline(f, sp)) {
        if (current_line + 1 == global_loc->line) {
            cout << precu << "" << filename << "(" << global_loc->line << ":"
                 << global_loc->col1 << ")"
                 << ": " << sp << endl;
            break;
        }
        current_line++;
    }
    f.close();
    cout << "\t" << aMessage << endl;
}

extern void
syntaxError(string aMessage)
{
    reportError(aMessage, "\033[1;31mError: \033[0m");
    exit(1);
}

extern void
semanticError(string aMessage, bool aCrash)
{
    reportError(aMessage, "\033[1;93mWarning: \033[0m");
    if (aCrash) {
        exit(1);
    }
}

extern void
semanticError(string aMessage)
{
    semanticError(aMessage, false);
}

bool
typeEqual(vector<Type*> a, vector<Type*> b)
{
    vector<Type*>::iterator it = a.begin();
    vector<Type*>::iterator jt = b.begin();
    for (; it != a.end() && jt != b.end(); (++it)) {
        if (**it != **jt)
            return false;
        ++jt;
    }
    return true;
}

extern vector<Type*>
verifyFunctionType(vector<FuncType*> cand_list, int count, Node* args, ST* curr)
{
    return verifyFunctionType(cand_list, count, args, curr, "");
}

extern vector<Type*>
verifyFunctionType(vector<FuncType*> cand_list,
                   int count,
                   Node* args,
                   ST* curr,
                   string structName)
{
    vector<Type*> types;
    if (count) {
        vector<Node*>::iterator it = args->children.begin();
        for (; it != args->children.end(); ++it) {
            fixNodeForExpression(*it, curr);
            types.push_back(correctType(*it, curr));
        }
    }
    if (structName.compare("") != 0) { // unequal
        count++;
        if (!curr->checkEntry(structName))
            types.insert(types.begin(), curr->getVar(structName)->getType());
        else {
            semanticError("Variable not found");
            exit(1);
        }
    }
    vector<FuncType*>::iterator cand = cand_list.begin();
    for (; cand != cand_list.end(); ++cand) {
        if (count == (*cand)->GetParamTypes().size() &&
            (typeEqual(types, (*cand)->GetParamTypes()))) {
            vector<Type*> type_list = (*cand)->GetParamTypes();
            type_list.push_back((*cand)->GetReturnType());
            type_list.push_back(*cand);
            return type_list;
        }
    }
    semanticError("Unknown function type");
    exit(1);
}
