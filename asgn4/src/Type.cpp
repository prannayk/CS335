#include "Type.h"
#include <ctime>

map<string, Type*> TypeList; // list of string to type* for reference

extern void fillTypeList (){
    TypeList["int"] = new BasicType("int");
    TypeList["int"]->mem_size = 4;
    TypeList["float"] = new BasicType("float");
    TypeList["float"]->mem_size = 8;
    TypeList["char"] = new BasicType("char");
    TypeList["char"]->mem_size = 1;
}

string
structRepr(map<string, Type*> fields)
{
    string repr = "struct{";
    for (auto const& field : fields) {
        repr += field.first + " " + field.second->GetRepresentation() + ";";
    }
    repr += "}";
    return repr;
}

Type::Type()
  : representation("")
  , type(0)
{}

string
Type::GetRepresentation() const
{
    return this->representation;
}

int
Type::GetTypeClass() const
{
    return this->type;
}

bool
Type::operator==(const Type& rhs)
{
    if (typeid(*this) != typeid(rhs)) {
        return false;
    }
    return this->GetRepresentation() == rhs.GetRepresentation();
}

bool
Type::operator!=(const Type& rhs)
{
    return !(*this == rhs);
}

BasicType::BasicType(string aName)
  : Type()
  , name(aName)
  , variadic(false)
// , pointer(false)
{
    if(TypeList.count(aName)){
        this->mem_size = TypeList[aName]->mem_size;
    }
    this->representation = aName;
    this->type = 1;
}

BasicType::BasicType(string aName, bool flag)
  : Type()
  , name(aName)
  , variadic(flag)
// , pointer(false)
{
    this->representation = aName;
    this->type = 1;
    if(TypeList.count(aName)){
        this->mem_size = TypeList[aName]->mem_size;
    }
}

string
BasicType::GetName() const
{
    return this->name;
}

FuncType::FuncType(Type* aReturnType, vector<Type*> aParamTypes, bool flag)
  : returnType(aReturnType)
  , paramTypes(aParamTypes)
  , generator(flag)
{
    if (flag)
        this->representation = "gen(";
    else
        this->representation = "func(";
    vector<Type*>::iterator it;
    for (it = paramTypes.begin(); it != paramTypes.end(); ++it) {
        this->representation += (*it)->GetRepresentation();
        if (it + 1 != paramTypes.end()) {
            this->representation += ", ";
        }
    }
    this->representation += ") " + returnType->GetRepresentation();
    this->type = 2;
    this->mem_size = 8; // store function type variables as function pointers and therefore take pointer amount of memory
}

FuncType::FuncType(Type* aReturnType, vector<Type*> aParamTypes)
  : returnType(aReturnType)
  , paramTypes(aParamTypes)
  , generator(false)
{
    this->representation = "func(";
    vector<Type*>::iterator it;
    for (it = paramTypes.begin(); it != paramTypes.end(); ++it) {
        this->representation += (*it)->GetRepresentation();
        if (it + 1 != paramTypes.end()) {
            this->representation += ", ";
        }
    }
    this->representation += ") " + returnType->GetRepresentation();
    this->type = 2;
    this->mem_size = 8; // store function type variables as function pointers and therefore take pointer amount of memory
}

Type*
FuncType::GetReturnType() const
{
    return this->returnType;
}

vector<Type*>
FuncType::GetParamTypes() const
{
    return this->paramTypes;
}

StructDefinitionType::StructDefinitionType(string aName,
                                           map<string, Type*> aFields)
  : fields(aFields)
  , randomSuffix(to_string(clock()))
{
    name = aName;
    this->representation = structRepr(this->fields);
    this->type = 3;
    int sum;
    std::map<string, Type*>::iterator it;
    for(it = aFields.begin(); it!=aFields.end(); ++it ){
        this->mem_size_list[it->first] = it->second->mem_size;
        sum+= it->second->mem_size;
    }
    this->mem_size = sum;
}

StructDefinitionType::StructDefinitionType(string aName,
                                           vector<string> fieldNames,
                                           vector<Type*> fieldTypes)
  : fields()
  , randomSuffix(to_string(clock()))
{

    name = aName;
    vector<string>::iterator ni;
    vector<Type*>::iterator ti;
    for (ni = fieldNames.begin(), ti = fieldTypes.begin();
         ni != fieldNames.end() && ti != fieldTypes.end();
         ++ni, ++ti) {
        this->fields[*ni] = *ti;
    }
    this->representation = structRepr(this->fields);
    this->type = 3;
    int sum;
    vector<string>::iterator first;
    vector<Type*>::iterator second;
    for(first = fieldNames.begin(); first!=fieldNames.end(); ++first ){
        this->mem_size_list[*first] = (*second)->mem_size;
        sum+= (*second)->mem_size;
    }
    this->mem_size = sum;
}

Type*
StructDefinitionType::GetTypeFor(string aFieldName)
{
    return this->fields[aFieldName];
}

string
StructDefinitionType::Hoist(string aStructVariableName,
                            string aFieldName,
                            string aSuffix) const
{
    return aStructVariableName + "_" + aFieldName + "_" + aSuffix;
}

CompoundType::CompoundType(vector<Type*> aParamTypes)
  : typeList(aParamTypes)
{
    this->representation = "(";
    vector<Type*>::iterator it;
    for (it = aParamTypes.begin(); it != aParamTypes.end(); ++it) {
        this->representation += (*it)->GetRepresentation();
        if (it + 1 != aParamTypes.end()) {
            this->representation += ", ";
        }
    }
    this->representation += ") ";
}

vector<Type*>
CompoundType::GetTypeList() const
{
    return this->typeList;
}

ArrayType::ArrayType(Type* aArrayType, int aSize)
  : arrayType(aArrayType)
  , size(aSize)
  , variadicSize(false)
{
    this->representation =
      "[" + to_string(aSize) + "]" + aArrayType->GetRepresentation();
    this->type = 4;
    this->mem_size = aArrayType->mem_size;
}

ArrayType::ArrayType(Type* aArrayType, int aSize, bool flag)
  : arrayType(aArrayType)
  , size(aSize)
  , variadicSize(flag)
{
    this->representation =
      "[" + to_string(aSize) + "]" + aArrayType->GetRepresentation();
    this->type = 4;
    this->mem_size = aArrayType->mem_size;
}

int
ArrayType::GetSize() const
{
    return this->size;
}

Type*
ArrayType::GetArrayType() const
{
    return this->arrayType;
}

PointerType::PointerType(Type* aUnderlyingType)
{
    this->underlyingType = aUnderlyingType;
    this->representation = "*" + this->underlyingType->GetRepresentation();
}

Type*
PointerType::GetUnderlyingType() const
{
    return this->underlyingType;
}

int Type::GetMemSize() const 
{
    return this->mem_size;
}
