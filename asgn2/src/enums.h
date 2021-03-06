#pragma once

enum OpCode
{
    // Enum numbering, if not assigned, is +1 the previous one
    // Binary math/bit operations
    ADD = 0,
    SUB,
    SL,
    SR,
    ASHR,
    AND,
    OR,
    XOR,
    MUL,
    DIV,
    MOD,

    // Binary relops
    GT = 50,
    LT,
    GEQ,
    LEQ,
    EQ,
    NEQ,

    // Binary control flow ops
    GOTOEQ = 100,
    GOTONEQ,
    GOTOLT,
    GOTOLEQ,
    GOTOGT,
    GOTOGEQ,

    // Memory/vector ops
    GETADDR = 150,
    FOLLOWPTR,
    EELEM,
    IELEM,

    // Unary math/bit operations
    NOT = 200,
    NEG,
    ASG,
    LNOT,
    // Unary control flow/special operations
    GOTO = 250,
    CALL,
    // function start and end operation
    FUNC_ST,
    FUNC_ET,
    PDECL_OP,
    // Nullary operations
    RET = 300,
    LABEL_ST,
    // print
    PRINTINT = 400,
    // null instruction as default
    NULL_IST = 1000,

};

enum AddressingMode
{
    REGISTER = 0,
    CONSTANT_VAL = 1,
    NONE_MODE,
};

enum Type
{
    INT = 1,
    BRANCH = 2,
    STRING,
    PTR,
    NONE_TYPE,
};

enum Register
{
    // Special registers, should never be returned from getReg
    RBP = -1,
    RSP = -2,
    RIP = -3,

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
