#pragma once

enum OpCode
{
    // Enum numbering, if not assigned, is +1 the previous one
    // Binary math/bit operations
    ADD_OPER = 0,
    SUB_OP,
    SL_OP,
    SR_OP,
    ASHR_OP,
    AND_OP, // logical AND
    OR_OP, // logical OR
    XOR_OP,
    BOR_OP, // bitwise OR
    BAND_OP, // bitwise AND
    MUL_OPER,
    DIV_OP,
    MOD_OP,
    NOT_OPER,
    NAND_OP, 
    
    // Binary relops
    GT_OP = 50,
    LT_OP,
    GEQ_OP,
    LEQ_OP,
    EQ_OP,
    NEQ_OP,

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
    INC_OP,
    DEC_OP,
    // Unary control flow/special operations
    GOTO_OP = 250,
    CALL,
    PARAM,
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
    STRING = 2,
    NONE_MODE,
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
