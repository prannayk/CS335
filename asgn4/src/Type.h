#pragma once

#include <iostream>
#include <map>
#include <string.h>
#include <vector>

using namespace std;

class Type
{
  public:
  bool operator==(const Type& rhs);
};

class BasicType : public Type
{
  private:
    string name;

  public:
    BasicType(string aName);
    bool operator==(const Type& rhs);
};

/* class FuncType : public Type */
/* { */
/*   private: */
/*     vector<Type*> params; */
/*     Type* returnType; */

/*   public: */
/*     vector<Type*> GetParams() const; */
/*     Type* GetReturnType() const; */
/*     FuncType(vector<Type*> aParams, Type* aReturnType); */
/*     bool operator==(const FuncType& rhs); */
/*     bool operator==(const Type& rhs); */
/* }; */

/* class StructType : public Type */
/* { */
/*   private: */
/*     map<string, Type*> fields; */
/*     string randomSuffix; */

/*   public: */
/*     map<string, Type*> GetFields() const; */
/*     string Hoist(string aStructVariableName, string aFieldName) const; */
/*     Type* GetTypeFor(string aFieldName) const; */
/*     StructType(map<string, Type*> aFields); */
/*     StructType(vector<string> fieldNames, vector<Type*> fieldTypes); */
/*     bool operator==(const StructType& rhs); */
/*     bool operator==(const Type& rhs); */
/* }; */
