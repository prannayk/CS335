%type   <sval>          BREAK
%type   <sval>          DEFAULT
%type   <sval>          FUNC
%type   <sval>          INTERFACE
%type   <sval>          SELECT
%type   <sval>          CASE
%type   <sval>          DEFER
%type   <sval>          GO
%type   <sval>          MAP
%type   <sval>          STRUCT
%type   <sval>          CHAN
%type   <sval>          ELSE
%type   <sval>          GOTO
%type   <sval>          PACKAGE
%type   <sval>          SWITCH
%type   <sval>          CONST
%type   <sval>          FALLTHROUGH
%type   <sval>          IF
%type   <sval>          RANGE
%type   <sval>          TYPE
%type   <sval>          CONTINUE
%type   <sval>          FOR
%type   <sval>          IMPORT
%type   <sval>          RETURN
%type   <sval>          VAR
%type   <sval>          NIL

%type   <sval>          COMMENT_ST
%type   <sval>          COMMENT_EN
%type   <sval>          COMMENT_LN

%type   <sval>          FOLDL
%type   <sval>          FOLDR
%type   <sval>          MMAP
%type   <sval>          YIELD
%type   <sval>          APPEND
%type   <sval>          CAP
%type   <sval>          CLOSE
%type   <sval>          COPY
%type   <sval>          DELETE
%type   <sval>          LEN
%type   <sval>          MAKE
%type   <sval>          NEW
%type   <sval>          PRINT
%type   <sval>          PRINTLN
%type   <sval>          GEN

%type   <sval>          GENERIC_CONCAT
%type   <sval>          GENERIC_NAME
%type   <sval>          GENERIC_BNAME
%type   <sval>          GENERIC_LIST

%type   <sval>          NEWLINE
%type   <sval>          UNICODE_CHAR
%type   <sval>          UNICODE_LETTER
%type   <sval>          LETTER

%type   <sval>          DECIMAL_DIGIT
%type   <sval>          OCTAL_DIGIT
%type   <sval>          HEX_DIGIT

%type   <sval>          ID

%type   <sval>          DECIMAL_LIT
%type   <sval>          OCTAL_LIT
%type   <sval>          HEX_LIT

%type   <sval>          INT_LIT


%type   <sval>          DECIMALS
%type   <sval>          EXP

%type   <sval>          FLOAT_LIT

%type   <sval>          OCTAL_BYTE
%type   <sval>          HEX_BYTE
%type   <sval>          BYTE_VAL
%type   <sval>          ESCAPE

%type   <sval>          RAW_STRING
%type   <sval>          INTER_STRING
%type   <sval>          STRING_LIT

%type   <sval>          UINT8
%type   <sval>          UINT16
%type   <sval>          UINT32
%type   <sval>          UINT64
%type   <sval>          INT8
%type   <sval>          INT16
%type   <sval>          INT32
%type   <sval>          INT64
%type   <sval>          FLOAT32
%type   <sval>          FLOAT64
%type   <sval>          BYTE
%type   <sval>          BOOL
%type   <sval>          UINT
%type   <sval>          INT
%type   <sval>          UINTPTR

%type   <sval>          OR
%type   <sval>          AND
%type   <sval>          LE
%type   <sval>          LT
%type   <sval>          GE
%type   <sval>          GT
%type   <sval>          EQ
%type   <sval>          NE
%type   <sval>          LS
%type   <sval>          RS
%type   <sval>          NOT_AND
%type   <sval>          INC
%type   <sval>          DEC
%type   <sval>          DECL
%type   <sval>          ADD
%type   <sval>          SUB
%type   <sval>          MUL
%type   <sval>          DIV
%type   <sval>          MOD
%type   <sval>          BIT_OR
%type   <sval>          BIT_AND
%type   <sval>          EXP_OP
%type   <sval>          NOT_OP
%type   <sval>          BIT_NOT
%type   <sval>          PTR_OP
%type   <sval>          REF_OP
%type   <sval>          STMTEND

%type   <sval>          TRUE
%type   <sval>          FALSE

%type   <sval>          REL_OP
%type   <sval>          ADD_OP
%type   <sval>          MUL_OP
%type   <sval>          UNARY_OP
%type   <sval>          BIN_OP

%type   <sval>          VARIADIC
%type   <sval>          ASSGN_OP

%type   <sval>          PAREN_OPEN
%type   <sval>          PAREN_CLOSE
%type   <sval>          BLOCK_OPEN
%type   <sval>          BLOCK_CLOSE
%type   <sval>          DOT

%%

expr:           
        ;

%%
