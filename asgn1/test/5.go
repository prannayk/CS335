package main;

import "fmt";

func badlog(y, x int) (int) {
    i := 1;
    count := 0;
    for ; i < y ; {
        count += 1;
        i *= x;
    }
    return count;
}

func baddiv(y, x int) (int) {
    count := 0;
    for  y > 0 {
        count += 1;
        y -= x;
    }
    return count;
}

func main() {
    fact := 1;
    for i:= 1; i < 7; i++ {
        fact *= i;
    }
    fmt.Println(fact);


    fmt.Println(badlog(9, 2));
    fmt.Println(baddiv(7, 2));


}
