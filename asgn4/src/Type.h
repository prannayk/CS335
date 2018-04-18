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
    int type;

  public:
    int mem_size;
    Type();
    string GetRepresentation() const;
    bool operator==(const Type& rhs);
    bool operator!=(const Type& rhs);
    int GetTypeClass() const;
    int GetMemSize() const;
};

class BasicType : public Type
{
  private:
    string name;
    int size;

  public:
    bool variadic;
    string GetName() const;
    BasicType(string aName);
    BasicType(string aName, bool flag);
    /* BasicType(string aName, bool flag, bool pointer); */
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
    map<string, int> mem_size_list;
    map<string, int> offset;
    map<string, FuncType*> structFunctions;

    map<string, Type*> GetFields() const;
    string Hoist(string aStructVariableName,
                 string aFieldName,
                 string aSuffix) const;
    Type* GetTypeFor(string aFieldName);
    StructDefinitionType(map<string, Type*> aFields);
    StructDefinitionType(vector<string> fieldNames,
                         vector<Type*> fieldTypes);
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
    bool variadicSize;

  public:
    int GetSize() const;
    Type* GetArrayType() const;
    ArrayType(Type* aArrayType, int aSize);
    ArrayType(Type* aArrayType, int aSize, bool flag);
};

class StructType : public Type
{
  private:
    Type* structType;
    string structName;
    StructDefinitionType* baseType;

  public:
    Type* GetStructType() const;
    Type* GetStructMemberType(string a);
    StructType(Type* aStructType, string aName, int aMem);
};

class PointerType : public Type
{
  private:
    Type* underlyingType;

  public:
    Type* GetUnderlyingType() const;
    PointerType(Type* aUnderlyingType);
};

extern map<string, Type*> TypeList;
extern void fillTypeList();
