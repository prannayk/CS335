#pragma once

enum OpCode
{
    ADD = 0,
    SUB = 1,
    MUL = 2,
    DIV = 3,
};

enum AddressingMode
{
    REGISTER = 0,
    CONSTANT = 1,
    ADDRESS = 2,
};

enum Type
{
    INT = 1,
};
