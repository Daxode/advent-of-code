package day1

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

input : string : #load("input.txt")

part1 :: proc() {
    fmt.println("Day 1 Part 1")
    input_str := input
    line_iter := &input_str
    left_col := make([dynamic]i32)
    right_col := make([dynamic]i32)
    for line in strings.split_lines_after_iterator(line_iter) {
        line_cpy := line
        line_split_iter := &line_cpy
        left, _ := strings.split_by_byte_iterator(line_split_iter, ' ')
        append(&left_col, i32(strconv.atoi(left)))
        append(&right_col, i32(strconv.atoi(line_split_iter^[2:])))
    }

    sort.quick_sort(left_col[:])
    sort.quick_sort(right_col[:])

    sum : i32 = 0
    for left, i in left_col {
        right := right_col[i]
        sum += abs(left-right)
    }
    fmt.println(sum)
}

part2 :: proc() {
    fmt.println("Day 1 Part 2")

    input_str := input
    line_iter := &input_str
    left_col := make([dynamic]i32)
    right_col := make([dynamic]i32)

    for line in strings.split_lines_after_iterator(line_iter) {
        line_cpy := line
        line_split_iter := &line_cpy
        left, _ := strings.split_by_byte_iterator(line_split_iter, ' ')
        append(&left_col, i32(strconv.atoi(left)))
        append(&right_col, i32(strconv.atoi(line_split_iter^[2:])))
    }

    simulol: i32 = 0
    for left in left_col {
        for right in right_col {
            if left == right {
                simulol += right
            }
        }
    }
    fmt.println(simulol)
}