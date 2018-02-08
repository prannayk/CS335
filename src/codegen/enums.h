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
};

enum Type
{
    INT = 1,
};

enum Register
{
    // Special registers, should never be returned from getReg
    RBP = -1,
    RSP = -2,

    // Special value denoting no register, should not be returned by getReg
    NONE = 0,

    // General purpose registers
    RAX = 1,
    RBX = 2,
    RCX = 3,
    RDX = 4,
    RSI = 5,
    RDI = 6,
    R8 = 7,
    R9 = 8,
    R10 = 9,
    R11 = 10,
    R12 = 11,
    R13 = 12,
    R14 = 13,
    R15 = 14,
};
