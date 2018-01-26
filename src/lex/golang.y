%union {
    char* str;
    double f64;
    float f32;
    int32_t i32;
    int64_t i64;
};

%token   <str>          BREAK
%token   <str>          DEFAULT
%token   <str>          FUNC
%token   <str>          INTERFACE
%token   <str>          SELECT
%token   <str>          CASE
%token   <str>          DEFER
%token   <str>          GO
%token   <str>          MAP
%token   <str>          STRUCT
%token   <str>          CHAN
%token   <str>          ELSE
%token   <str>          GOTO
%token   <str>          PACKAGE
%token   <str>          SWITCH
%token   <str>          CONST
%token   <str>          FALLTHROUGH
%token   <str>          IF
%token   <str>          RANGE
%token   <str>          TYPE
%token   <str>          CONTINUE
%token   <str>          FOR
%token   <str>          IMPORT
%token   <str>          RETURN
%token   <str>          VAR
%token   <str>          NIL

%token   <str>          COMMENT_ST
%token   <str>          COMMENT_EN
%token   <str>          COMMENT_LN

%token   <str>          FOLDL
%token   <str>          FOLDR
%token   <str>          MMAP
%token   <str>          YIELD
%token   <str>          APPEND
%token   <str>          CAP
%token   <str>          CLOSE
%token   <str>          COPY
%token   <str>          DELETE
%token   <str>          LEN
%token   <str>          MAKE
%token   <str>          NEW
%token   <str>          PRINT
%token   <str>          PRINTLN
%token   <str>          GEN

%token   <str>          GENERIC_CONCAT
%token   <str>          GENERIC_NAME
%token   <str>          GENERIC_BNAME
%token   <str>          GENERIC_LIST

%token   <str>          NEWLINE
%token   <str>          UNICODE_CHAR
%token   <str>          UNICODE_LETTER
%token   <str>          LETTER

%token   <str>          DECIMAL_DIGIT
%token   <str>          OCTAL_DIGIT
%token   <str>          HEX_DIGIT

%token   <str>          ID

%token   <str>          DECIMAL_LIT
%token   <str>          OCTAL_LIT
%token   <str>          HEX_LIT

%token   <str>          INT_LIT


%token   <str>          DECIMALS
%token   <str>          EXP

%token   <str>          FLOAT_LIT

%token   <str>          OCTAL_BYTE
%token   <str>          HEX_BYTE
%token   <str>          BYTE_VAL
%token   <str>          ESCAPE

%token   <str>          RAW_STRING
%token   <str>          INTER_STRING
%token   <str>          STRING_LIT

%token   <i32>          UINT8
%token   <i32>          UINT16
%token   <i64>          UINT32
%token   <i64>          UINT64
%token   <i32>          INT8
%token   <i32>          INT16
%token   <i32>          INT32
%token   <i64>          INT64
%token   <f32>          FLOAT32
%token   <f64>          FLOAT64
%token   <str>          BYTE
%token   <i32>          BOOL
%token   <i64>          UINT
%token   <i32>          INT
%token   <i64>          UINTPTR

%token   <str>          OR
%token   <str>          AND
%token   <str>          LE
%token   <str>          LT
%token   <str>          GE
%token   <str>          GT
%token   <str>          EQ
%token   <str>          NE
%token   <str>          LS
%token   <str>          RS
%token   <str>          NOT_AND
%token   <str>          INC
%token   <str>          DEC
%token   <str>          DECL
%token   <str>          ADD
%token   <str>          SUB
%token   <str>          MUL
%token   <str>          DIV
%token   <str>          MOD
%token   <str>          BIT_OR
%token   <str>          BIT_AND
%token   <str>          EXP_OP
%token   <str>          NOT_OP
%token   <str>          BIT_NOT
%token   <str>          PTR_OP
%token   <str>          REF_OP
%token   <str>          STMTEND

%token   <str>          TRUE
%token   <str>          FALSE

%token   <str>          REL_OP
%token   <str>          ADD_OP
%token   <str>          MUL_OP
%token   <str>          UNARY_OP
%token   <str>          BIN_OP

%token   <str>          VARIADIC
%token   <str>          ASSGN_OP

%token   <str>          PAREN_OPEN
%token   <str>          PAREN_CLOSE
%token   <str>          BLOCK_OPEN
%token   <str>          BLOCK_CLOSE
%token   <str>          DOT

%%

expr:   OCTAL_BYTE
        ;

%%
