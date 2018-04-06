#pragma once

#include "helpers.h"
#include <fstream>
#include <iostream>
struct myLoc
{
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};

extern myLoc* global_loc;
using namespace std;

class ErrorHandler {
 private:
  myLoc* location;
  string filename;
  void ReportError();
 public:
  ErrorHandler(myLoc* aLocation, string aFilename);
  void SyntaxError(string aErrorStatement);
  void SemanticError(string aErrorStatement);
  void SemanticError(string aErrorStatement, bool crash);
};

