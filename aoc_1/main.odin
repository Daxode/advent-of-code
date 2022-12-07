package aoc_1

import "core:fmt"

main :: proc(){
    input := #load("input.txt")
    for l in input {
        fmt.println(l)
    }
    fmt.println(len(input))
}