# CS335 Assignment 1

## Prerequisites

* g++ (we tested with g++ 7.2.1)
* bison (we tested with bison 3.0.4)
* flex (we tested with flex 2.6.4)

## Instructions

``` shell
$ cd asgn4
$ make
$ ./pogo filename
```

Pogo calls scripts prepare.sh which adds semicolons, as is standard in go compilers. It then runs the parser on the file, stores the output x86 in a temp file, which is then compiled using clang, to generate the final output file.

## Acknowledgements:
We took some  test cases from the Golang examples (repository)[https://github.com/golang/go/blob/release-branch.go1.4/test/ken/] and the GoByExample (website)[https://github.com/golang/go/blob/release-branch.go1.4/test/ken/].
