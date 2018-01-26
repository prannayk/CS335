package main

import "fmt"

func second(x, y string) (string) {
    return y
}

func main() {
    a:= second("hello", "world")
    fmt.Println(a)
}



