# CS335 Assignment 1

## Prerequisites

* g++ (we tested with g++ 7.2.1)
* bison (we tested with bison 3.0.4)
* flex (we tested with flex 2.6.4)

## Instructions

``` shell
$ cd asgn1
$ make
$ make (test | clean) or bin/lexer test/1.go
```

`make test` will test all 10 test files and print the output.

As done for the 'identifiers' in the Assignment 1 example, the occurances
are only the unique occurances (number of unique lexemes per token).

## Test cases 
Functionality being demonstrated by every test file (added functionality is **bold**):

1. ``` 1.gop ``` : Loop variants and string constructs
2. ``` 2.gop ``` : Conditionals and switch statements
3. ``` 3.gop ``` : Functions and **Generators**
4. ``` 4.gop ``` : Struct and Interface
5. ``` 5.gop ``` : **Generics**
6. ``` 6.gop ``` : Labels for jumping etc
7. ``` 7.gop ``` : Extensive Literals **not done**
8. ``` 8.gop ``` : Strings, arrays, slicing
9. ``` 9.gop ``` : TypeCasting
10. ``` 10.gop ``` : Embeds for Golang

## Acknowledgements:
We took test cases from the Golang examples (repository)[https://github.com/golang/go/blob/release-branch.go1.4/test/ken/] and the GoByExample (website)[https://github.com/golang/go/blob/release-branch.go1.4/test/ken/].
