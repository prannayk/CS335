package main;

import "fmt";

func<A, B> foldr(func f(a A, b B) B, id B, []A lst) B {
    if len(lst) == 0 {
        return id;
    }
    return f(head(A), foldr(f, id, tail(A)));
}


gen TillTen() int {
    for i := 0; i != 10; i++ {
        yield i
    }
    return 0
}
