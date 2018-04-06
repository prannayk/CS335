#include "ErrorHandler.h"

#define REPORTERR(_fname, _ln, _coln, _line)                                   \
    cout << "\033[1;31mError: \033[0m" << _fname << "(" << _ln << ":" << _coln \
         << ")"                                                                \
         << ": " << _line << endl;

ErrorHandler::ErrorHandler(myLoc* aLocation, string aFilename)
  : location(aLocation)
  , filename(aFilename)
{}

void
ErrorHandler::ReportError()
{
    string sp;
    ifstream f;
    f.open(filename, ios::in);
    int current_line = 0;
    while (getline(f, sp)) {
        if (current_line + 1 == this->location->line) {
            cout << "\033[1;31mError: \033[0m" << this->filename << "("
                 << this->location->line << ":" << this->location->col1 << ")"
                 << ": " << sp << endl;
            break;
        }
        current_line++;
    }
}

void
ErrorHandler::SyntaxError(string aErrorStatement)
{
    this->ReportError();
    cout << aErrorStatement << endl;
    exit(1);
}

void
ErrorHandler::SemanticError(string aErrorStatement)
{
    SemanticError(aErrorStatement, false);
}

void
ErrorHandler::SemanticError(string aErrorStatement, bool crash)
{
    this->ReportError();
    cout << aErrorStatement << endl;
    if (crash) {
        exit(1);
    }
}
