#pragma once

enum OpCode
{
    ADD = 0,
    SUB = 1,
    MUL = 2,
    DIV = 3,
    SL = 4,
    SR = 5,
    GT = 6,
    LT = 7,
    GEQ = 8,
    LEQ = 9,

};

enum AddressingMode
{
    REGISTER = 0,
    CONSTANT_VAL = 1,
    ADDRESS = 2,
};

enum Type
{
    INT = 1,
};
