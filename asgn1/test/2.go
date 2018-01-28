package main;

import "fmt";

func main() {
    a:= 7;
    b:= 5;
    fmt.Println("Testing math operators on ints");
    fmt.Println(a+b, a-b, a*b, a/b);
    fmt.Println((100 * (a + b))/(a % (a * b)));

    fmt.Println("Testing bitwise operators");
    fmt.Println(a^b, a&b, a>>2, b<<2);

    c:= 7.7;
    d:= 5.2;
    fmt.Println("Testing math operators on floats");
    fmt.Println(c+d, c-d, c*d, c/d);
}
