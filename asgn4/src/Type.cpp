#include "Type.h"
#include <ctime>

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

BasicType::BasicType(string aName)
  : Type()
  , name(aName)
  , variadic(false)
  , pointer(false)
{
    this->representation = aName;
    this->type = 1;
}

BasicType::BasicType(string aName, bool flag)
  : Type()
  , name(aName)
  , variadic(flag)
  , pointer(false)
{
    this->representation = aName;
    this->type = 1;
}

BasicType::BasicType(string aName, bool aFlag, bool aPointer)
  : Type()
  , name(aName)
  , variadic(aFlag)
  , pointer(aPointer)
{
    string star = "*";
    this->representation = star + aName;
    this->type = 1;
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

StructDefinitionType::StructDefinitionType(string aName, map<string, Type*> aFields)
  : fields(aFields)
  , randomSuffix(to_string(clock()))
{
    name = aName;
    this->representation = structRepr(this->fields);
    this->type = 3;
}

StructDefinitionType::StructDefinitionType(string aName, vector<string> fieldNames, vector<Type*> fieldTypes)
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
}

Type*
StructDefinitionType::GetTypeFor(string aFieldName)
{
    return this->fields[aFieldName];
}

string
StructDefinitionType::Hoist(string aStructVariableName, string aFieldName, string aSuffix) const
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
}

ArrayType::ArrayType(Type* aArrayType, int aSize, bool flag)
  : arrayType(aArrayType)
  , size(aSize)
  , variadicSize(flag)
{
    this->representation =
      "[" + to_string(aSize) + "]" + aArrayType->GetRepresentation();
    this->type = 4;
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
