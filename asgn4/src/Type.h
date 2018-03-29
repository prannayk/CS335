#pragma once

#include <iostream>
#include <map>
#include <string.h>
#include <vector>
#include <ctime>
#include <typeinfo>

using namespace std;

class Type
{
  protected:
    string representation;

  public:
    Type();
    string GetRepresentation() const;
    bool operator==(const Type& rhs);
};

class BasicType : public Type
{
  private:
    string name;

  public:
    string GetName() const;
    BasicType(string aName);
};

class FuncType : public Type
{
  private:
    Type* returnType;
    vector<Type*> paramTypes;

  public:
    Type* GetReturnType() const;
    vector<Type*> GetParamTypes() const;
    FuncType(Type* aReturnType, vector<Type*> aParamTypes);
};

class StructType : public Type
{
  private:
    map<string, Type*> fields;
    string randomSuffix;

  public:
    map<string, Type*> GetFields() const;
    string Hoist(string aStructVariableName, string aFieldName) const;
    Type* GetTypeFor(string aFieldName);
    StructType(map<string, Type*> aFields);
    StructType(vector<string> fieldNames, vector<Type*> fieldTypes);
};
