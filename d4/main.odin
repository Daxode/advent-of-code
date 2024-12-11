package day4

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

input : string : #load("input.txt")

part1 :: proc() {
    fmt.println("Day 4 Part 1")

    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    for line in strings.split_lines_iterator(line_iter) {
        line_cpy := line
        rawval_iter := &line_cpy
        
    }
    fmt.println(sum)
}

part2 :: proc() {
    fmt.println("Day 4 Part 2")


    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    for line in strings.split_lines_iterator(line_iter) {
        line_cpy := line
        rawval_iter := &line_cpy
        

    }
    fmt.println(sum)
}