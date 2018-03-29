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
{}

string
Type::GetRepresentation() const
{
    return this->representation;
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
{
    this->representation = aName;
}

string
BasicType::GetName() const
{
    return this->name;
}

FuncType::FuncType(Type* aReturnType, vector<Type*> aParamTypes)
  : returnType(aReturnType)
  , paramTypes(aParamTypes)
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

StructType::StructType(map<string, Type*> aFields)
  : fields(aFields)
  , randomSuffix(to_string(clock()))
{
    this->representation = structRepr(this->fields);
}

StructType::StructType(vector<string> fieldNames, vector<Type*> fieldTypes)
  : fields()
  , randomSuffix(to_string(clock()))
{
    vector<string>::iterator ni;
    vector<Type*>::iterator ti;
    for (ni = fieldNames.begin(), ti = fieldTypes.begin();
         ni != fieldNames.end() && ti != fieldTypes.end();
         ++ni, ++ti) {
        this->fields[*ni] = *ti;
    }
    this->representation = structRepr(this->fields);
}

Type*
StructType::GetTypeFor(string aFieldName)
{
    return this->fields[aFieldName];
}

string
StructType::Hoist(string aStructVariableName, string aFieldName) const
{
    return aStructVariableName + "_" + aFieldName + "_" + this->randomSuffix;
}
