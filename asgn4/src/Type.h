#pragma once

#include <ctime>
#include <iostream>
#include <map>
#include <string.h>
#include <typeinfo>
#include <vector>

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
    bool variadic;
    bool pointer;

  public:
    string GetName() const;
    BasicType(string aName);
    BasicType(string aName, bool flag);
    BasicType(string aName, bool flag, bool pointer);
};

class FuncType : public Type
{
  private:
    Type* returnType;
    vector<Type*> paramTypes;
    bool generator;

  public:
    Type* GetReturnType() const;
    vector<Type*> GetParamTypes() const;
    FuncType(Type* aReturnType, vector<Type*> aParamTypes, bool flag);
    FuncType(Type* aReturnType, vector<Type*> aParamTypes);
};

class StructDefinitionType : public Type
{

  public:
    map<string, Type*> fields;
    string randomSuffix;
    string name;

    map<string, Type*> GetFields() const;
    string Hoist(string aStructVariableName, string aFieldName, string aSuffix) const;
    Type* GetTypeFor(string aFieldName);
    StructDefinitionType(string aName, map<string, Type*> aFields);
    StructDefinitionType(string aName, vector<string> fieldNames, vector<Type*> fieldTypes);
};

class CompoundType : public Type
{
  private:
    vector<Type*> typeList;

  public:
    vector<Type*> GetTypeList() const;
    CompoundType(vector<Type*> aParamTypes);
};

class ArrayType : public Type
{
  private:
    Type* arrayType;
    int size;

  public:
    int GetSize() const;
    Type* GetArrayType() const;
    ArrayType(Type* aArrayType, int aSize);
};
