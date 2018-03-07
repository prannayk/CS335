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

`make test` will test all 6 test files and print the output.

As done for the 'identifiers' in the Assignment 1 example, the occurances
are only the unique occurances (number of unique lexemes per token).
