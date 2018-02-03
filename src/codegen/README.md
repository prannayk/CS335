For formatting, please install `clang-format` and run

``` shell
$ clang-format -i -style='{BasedOnStyle: mozilla, IndentWidth: 4}'  *.h
$ clang-format -i -style='{BasedOnStyle: mozilla, IndentWidth: 4}'  *.cpp
```

This will format all files in place, and we can do whatever we want while editing.

More info at: https://clang.llvm.org/docs/ClangFormat.html
