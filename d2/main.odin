package day2

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

input : string : #load("input.txt")

part1 :: proc() {
    fmt.println("Day 2 Part 1")

    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    for line in strings.split_lines_iterator(line_iter) {
        line_cpy := line
        rawval_iter := &line_cpy
        is_all_ascending := true
        is_all_descending := true
        last_val: Maybe(string)
        for rawval in strings.split_by_byte_iterator(rawval_iter, ' ') {
            if last_val != nil {
                // do per pair work here lol
                left_val := strconv.atoi(last_val.(string))
                right_val := strconv.atoi(rawval)
                diff := abs(left_val-right_val)
                
                if left_val > right_val {
                    is_all_ascending = false
                }
                if left_val < right_val {
                    is_all_descending = false
                }
                if diff > 3 || diff < 1 {
                    is_all_ascending = false
                    is_all_descending = false
                }
            }
            last_val = rawval
        }

        if is_all_ascending || is_all_descending {
            fmt.println("safe", line)
            sum += 1
        }
    }
    fmt.println(sum)
}

part2 :: proc() {
    fmt.println("Day 2 Part 2")


    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    for line in strings.split_lines_iterator(line_iter) {
        line_cpy := line
        rawval_iter := &line_cpy
        values := make([dynamic]i32)
        for rawval in strings.split_by_byte_iterator(rawval_iter, ' ') {
            append(&values, i32(strconv.atoi(rawval)))
        }

        is_safe := false
        for value_index_to_skip in 0..<len(values) {
            is_all_ascending := true
            is_all_descending := true
            
            last_val: Maybe(i32)
            debug_list := make([dynamic]i32)
            for value, i in values {
                if i == value_index_to_skip {
                    continue;
                }
                append(&debug_list, value)

                if (last_val != nil) {
                    left_val := last_val.(i32)
                    right_val := value
                    diff := abs(left_val-right_val)
                    
                    if left_val > right_val {
                        is_all_ascending = false
                    }
                    if left_val < right_val {
                        is_all_descending = false
                    }
                    if diff > 3 || diff < 1 {
                        is_all_ascending = false
                        is_all_descending = false
                    }
                }
                last_val = value
            }

            if is_all_ascending || is_all_descending {
                is_safe = true
                // fmt.println("safe", is_all_ascending, is_all_descending, debug_list)
            }
        }

        if is_safe {
            // fmt.println("safe", line)
            sum += 1
        }

    }
    fmt.println(sum)
}